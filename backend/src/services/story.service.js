import { admin, db } from '../config/firebase.js';
import geminiService from './gemini.service.js';
import gamificationService from './gamification.service.js';
import userService from './user.service.js';

const COOLDOWN_SECONDS = 30; // İki masal arası bekleme süresi

class StoryService {

    /**
     * Generate 10-character alphanumeric story ID
     */
    generateStoryId() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < 10; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    /**
     * 30 saniyelik cooldown kontrolü
     */
    async checkCooldown(userId) {
        const userDoc = await db.collection('users').doc(userId).get();
        if (!userDoc.exists) return { allowed: true };

        const lastTaleAt = userDoc.data().lastTaleAt;
        if (!lastTaleAt) return { allowed: true };

        const lastTime = new Date(lastTaleAt).getTime();
        const now = Date.now();
        const diffSec = (now - lastTime) / 1000;

        if (diffSec < COOLDOWN_SECONDS) {
            const waitSec = Math.ceil(COOLDOWN_SECONDS - diffSec);
            return { allowed: false, waitSeconds: waitSec };
        }

        return { allowed: true };
    }

    /**
     * Masal üret (Firestore'a kaydetmez — kullanıcı manuel kaydeder)
     */
    async generateStory(userId, storyParams) {
        try {
            // 1. Cooldown kontrolü
            const cooldown = await this.checkCooldown(userId);
            if (!cooldown.allowed) {
                throw new Error(`COOLDOWN:${cooldown.waitSeconds}`);
            }

            // 1.5. Masal limiti kontrolü (Max 10)
            const storyCount = await this.countUserStories(userId);
            if (storyCount >= 10) {
                throw new Error('LIMIT_REACHED');
            }

            // 2. Puzzle için günlük eligibility kontrol
            const isFirstDailyStory = await gamificationService.checkDailyPuzzleEligibility
                ? await gamificationService.checkDailyPuzzleEligibility(userId)
                : true;

            // Fallback: UserDoc'tan direkt kontrol
            const userDoc = await db.collection('users').doc(userId).get();
            const todayStr = new Date().toISOString().split('T')[0];
            const lastPieceDate = userDoc.data()?.puzzleProgress?.lastPieceDate || null;
            const puzzleEligible = lastPieceDate !== todayStr;

            // 3. Cooldown timestamp güncelle (spam önleme)
            await db.collection('users').doc(userId).update({
                lastTaleAt: new Date().toISOString()
            });

            // 4. AI ile masal üret
            const generatedContent = await geminiService.generateStory(storyParams);

            if (!generatedContent) {
                throw new Error('Masal üretilemedi');
            }

            // 5. Masalı Kaydetmeden Dön (Artık kullanıcı manuel kaydedecek)
            const storyData = {
                input: storyParams,
                content: generatedContent,
            };

            return {
                ...storyData,
                isSaved: false,
                storyId: null, // Henüz kaydedilmediği için ID yok
                puzzleEligible: puzzleEligible,
                message: 'Masal başarıyla oluşturuldu! ✨'
            };

        } catch (error) {
            console.error('StoryService.generateStory Error:', error);
            throw error;
        }
    }

    async getStoryById(userId, storyId) {
        const doc = await db.collection('users')
            .doc(userId)
            .collection('stories')
            .doc(storyId)
            .get();

        if (!doc.exists) return null;
        return { id: doc.id, ...doc.data() };
    }

    async countUserStories(userId) {
        const snapshot = await db.collection('users')
            .doc(userId)
            .collection('stories')
            .count()
            .get();

        return snapshot.data().count;
    }

    async getUserStories(userId) {
        console.log(`📖 getUserStories called for userId: ${userId}`);
        const snapshot = await db.collection('users')
            .doc(userId)
            .collection('stories')
            .orderBy('savedAt', 'desc')
            .get();

        console.log(`📖 Found ${snapshot.docs.length} stories in Firestore`);
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    }

    async deleteStory(storyId, userId) {
        const storyRef = db.collection('users')
            .doc(userId)
            .collection('stories')
            .doc(storyId);

        const doc = await storyRef.get();

        if (!doc.exists) {
            throw new Error('Story not found');
        }

        await storyRef.delete();
        console.log(`✅ Story ${storyId} deleted from Firestore`);

        // Görselleri Storage'dan silmeye çalış (hata olursa görmezden gel)
        try {
            const bucket = admin.storage().bucket();
            await bucket.deleteFiles({
                prefix: `users/${userId}/stories/${storyId}/`
            });
            console.log(`🗑️ Storage files deleted for story ${storyId}`);
        } catch (storageError) {
            console.warn(`⚠️ Could not delete storage files for ${storyId}: ${storageError.message}`);
        }

        return true;
    }

    /**
     * Masalı kitaplığa kaydet (kullanıcı 4. sayfanın sonunda butonla tetikler)
     */
    async saveStoryToLibrary(userId, storyData) {
        try {
            // 1. 8 haneli ID oluştur
            const storyId = this.generateStoryId();
            console.log(`📝 Saving story ${storyId} for user: ${userId}`);

            // 2. Görselleri Firebase Storage'a yükle
            console.log('📤 Uploading images to Firebase Storage...');
            const { default: storageService } = await import('./storage.service.js');

            if (storyData.content && storyData.content.segments) {
                storyData.content.segments = await storageService.uploadStoryImages(
                    storyData.content.segments,
                    userId,
                    storyId
                );
            }

            // 3. Firestore'a kaydet
            const storyToSave = {
                storyId: storyId,
                ...storyData,
                userId: userId,
                savedAt: admin.firestore.FieldValue.serverTimestamp(),
                isPremade: false,
                metadata: {
                    isFavorite: false,
                    readCount: 0,
                    ...storyData.metadata
                }
            };

            const storyRef = db.collection('users')
                .doc(userId)
                .collection('stories')
                .doc(storyId);

            await storyRef.set(storyToSave);
            console.log(`✅ Story saved: users/${userId}/stories/${storyId}`);

            // 4. Kullanıcı ilerlemesini güncelle (puzzle + haftalık rozet)
            const progressResult = await userService.updateProgressForStory(userId);

            // 5. Başarım kontrolü tetikle
            const userDoc = await db.collection('users').doc(userId).get();
            const userData = userDoc.data();
            const achievementResult = await gamificationService.checkAndUpdateAchievements(userId, {
                totalStoriesRead: userData.storiesCreated || 0,
                weeklyBadgeCount: (userData.badges || []).filter(b => b.startsWith('weekly_')).length
            });

            return {
                success: true,
                storyId: storyId,
                message: 'Masal kitaplığa eklendi!',
                newBadges: progressResult.newBadges || [],
                puzzleUpdate: progressResult.puzzleUpdate || {},
                unlockedAchievements: achievementResult.unlockedAchievements || [],
                jetonEarned: achievementResult.totalJetonEarned || 0
            };

        } catch (error) {
            console.error('StoryService.saveStoryToLibrary Error:', error);
            throw error;
        }
    }

    /**
     * Masalı favorilere ekle (önce kütüphanede olmalı)
     */
    async toggleFavorite(userId, storyId, isFavorite) {
        const storyRef = db.collection('users')
            .doc(userId)
            .collection('stories')
            .doc(storyId);

        const doc = await storyRef.get();
        if (!doc.exists) throw new Error('Masal bulunamadı');

        await storyRef.update({
            'metadata.isFavorite': isFavorite
        });

        return { success: true, isFavorite };
    }
}

export default new StoryService();
