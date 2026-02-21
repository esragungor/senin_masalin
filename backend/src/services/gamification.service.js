import { db } from '../config/firebase.js';
import userService from './user.service.js';

/**
 * Başarım Kataloğu
 * order_index sırasıyla ilerler — önceki tamamlanmadan sonraki açılmaz.
 * trigger_type: 'tales_read' | 'weekly_badge' | 'preset_read_time'
 */
const ACHIEVEMENT_CATALOG = [
    {
        id: 'ach_1',
        order_index: 1,
        title: 'İlk Adım',
        description: 'İlk masalını oluştur ve oku.',
        badge_image: 'badge_first_step',
        jeton_reward: 10,
        trigger_type: 'tales_read',
        trigger_value: 1
    },
    {
        id: 'ach_2',
        order_index: 2,
        title: 'Masal Dostu',
        description: '5 masal oku.',
        badge_image: 'badge_tale_friend',
        jeton_reward: 20,
        trigger_type: 'tales_read',
        trigger_value: 5
    },
    {
        id: 'ach_3',
        order_index: 3,
        title: 'Haftalık Kahraman',
        description: 'Bir haftada 7 masal oku.',
        badge_image: 'badge_weekly_hero',
        jeton_reward: 30,
        trigger_type: 'weekly_badge',
        trigger_value: 1
    },
    {
        id: 'ach_4',
        order_index: 4,
        title: 'Masal Ustası',
        description: '10 masal oku.',
        badge_image: 'badge_tale_master',
        jeton_reward: 50,
        trigger_type: 'tales_read',
        trigger_value: 10
    },
    {
        id: 'ach_5',
        order_index: 5,
        title: 'Yıldız Okuyucu',
        description: '25 masal oku.',
        badge_image: 'badge_star_reader',
        jeton_reward: 75,
        trigger_type: 'tales_read',
        trigger_value: 25
    },
    {
        id: 'ach_6',
        order_index: 6,
        title: 'Efsane Masal Anlatıcısı',
        description: '50 masal oku.',
        badge_image: 'badge_legend',
        jeton_reward: 100,
        trigger_type: 'tales_read',
        trigger_value: 50
    }
];

class GamificationService {

    /**
     * Kullanıcının aktif başarımını kontrol eder ve tamamlananları işler.
     * Başarımlar sıralıdır — önceki tamamlanmadan sonraki açılmaz.
     * @param {string} userId
     * @param {object} stats - { totalStoriesRead, weeklyBadgeCount, presetReadTimeSec }
     * @returns {Promise<{unlockedAchievements: Array, totalJetonEarned: number}>}
     */
    async checkAndUpdateAchievements(userId, stats) {
        try {
            const userRef = db.collection('users').doc(userId);
            const userDoc = await userRef.get();
            if (!userDoc.exists) return { unlockedAchievements: [], totalJetonEarned: 0 };

            const userData = userDoc.data();
            const completedIds = userData.completedAchievements || [];
            const unlockedAchievements = [];
            let totalJetonEarned = 0;

            // Sıralı kontrol — sadece bir sonraki aktif başarım kontrol edilir
            for (const ach of ACHIEVEMENT_CATALOG) {
                if (completedIds.includes(ach.id)) continue; // Zaten tamamlanmış

                // Bir önceki tamamlandı mı? (order_index 1 için direkt geç)
                if (ach.order_index > 1) {
                    const prev = ACHIEVEMENT_CATALOG.find(a => a.order_index === ach.order_index - 1);
                    if (prev && !completedIds.includes(prev.id)) {
                        break; // Önceki tamamlanmamış, devam etme
                    }
                }

                // Tetikleyici kontrolü
                let isCompleted = false;
                switch (ach.trigger_type) {
                    case 'tales_read':
                        isCompleted = (stats.totalStoriesRead || 0) >= ach.trigger_value;
                        break;
                    case 'weekly_badge':
                        isCompleted = (stats.weeklyBadgeCount || 0) >= ach.trigger_value;
                        break;
                    case 'preset_read_time':
                        isCompleted = (stats.presetReadTimeSec || 0) >= ach.trigger_value;
                        break;
                }

                if (isCompleted) {
                    // Başarımı tamamla
                    await db.runTransaction(async (transaction) => {
                        const freshDoc = await transaction.get(userRef);
                        const freshData = freshDoc.data();
                        const freshCompleted = freshData.completedAchievements || [];

                        if (!freshCompleted.includes(ach.id)) {
                            transaction.update(userRef, {
                                completedAchievements: [...freshCompleted, ach.id],
                                jetonBalance: (freshData.jetonBalance || 0) + ach.jeton_reward
                            });
                        }
                    });

                    // Jeton işlem kaydı
                    await userService.updateJetonBalance(userId, ach.jeton_reward, 'achievement_reward', ach.id);

                    unlockedAchievements.push(ach);
                    totalJetonEarned += ach.jeton_reward;
                    completedIds.push(ach.id); // Local güncelle

                    console.log(`✅ Achievement unlocked: ${ach.title} (+${ach.jeton_reward} jeton)`);

                    break; // Bir seferde yalnızca 1 başarım tamamlanabilir
                }

                break; // Aktif başarım tamamlanmadıysa dur
            }

            return { unlockedAchievements, totalJetonEarned };

        } catch (error) {
            console.error('GamificationService.checkAndUpdateAchievements Error:', error);
            return { unlockedAchievements: [], totalJetonEarned: 0 };
        }
    }

    /**
     * Hazır masal okuma süresi başarımı (90 saniye = 1.5 dakika)
     * Başarım sadece 1 kez kazanılabilir.
     */
    async checkPresetReadAchievement(userId, presetTaleId, timeSpentSeconds) {
        if (timeSpentSeconds < 90) return { achieved: false };

        try {
            const userRef = db.collection('users').doc(userId);
            const userDoc = await userRef.get();
            if (!userDoc.exists) return { achieved: false };

            const userData = userDoc.data();
            const readKey = `preset_${presetTaleId}`;
            const alreadyEarned = (userData.presetAchievements || []).includes(readKey);

            if (alreadyEarned) return { achieved: false };

            // Kaydet
            await userRef.update({
                presetAchievements: [...(userData.presetAchievements || []), readKey]
            });

            // Başarım kontrolü tetikle
            const stats = {
                totalStoriesRead: userData.totalStoriesRead || 0,
                presetReadTimeSec: timeSpentSeconds
            };
            const result = await this.checkAndUpdateAchievements(userId, stats);

            return { achieved: true, ...result };

        } catch (error) {
            console.error('GamificationService.checkPresetReadAchievement Error:', error);
            return { achieved: false };
        }
    }

    /**
     * Avatar satın alma
     */
    async purchaseAvatar(userId, avatarItemId) {
        const avatarRef = db.collection('avatar_items').doc(avatarItemId);
        const avatarDoc = await avatarRef.get();

        if (!avatarDoc.exists) throw new Error('Avatar bulunamadı');

        const avatarData = avatarDoc.data();

        if (avatarData.is_free) {
            // Ücretsiz — direkt ver
        } else {
            // Jeton düş
            await userService.updateJetonBalance(userId, -avatarData.jeton_cost, 'avatar_purchase', avatarItemId);
        }

        // Avatar açılımını kaydet
        await db.collection('users').doc(userId)
            .collection('avatar_unlocks').doc(avatarItemId)
            .set({ unlocked_at: new Date() });

        return { success: true, avatarId: avatarItemId };
    }

    /**
     * Kullanıcının aktif (tamamlanmamış) başarımını getir
     */
    getNextAchievement(completedIds) {
        for (const ach of ACHIEVEMENT_CATALOG) {
            if (!completedIds.includes(ach.id)) return ach;
        }
        return null; // Tümü tamamlandı
    }

    /**
     * Tüm başarım kataloğunu getir
     */
    getAllAchievements() {
        return ACHIEVEMENT_CATALOG;
    }
}

export default new GamificationService();
