import storyService from "../services/story.service.js";
import userService from "../services/user.service.js";
import gamificationService from "../services/gamification.service.js";
import { db } from "../config/firebase.js";

// ── Masal Oluştur ─────────────────────────────────────────────────────────────
export const createStory = async (req, res) => {
    try {
        const { childName, age, gender, theme, companion, specialObject, moral } = req.body;
        const userId = req.user.uid;

        await userService.getOrCreateUser({ uid: userId, email: req.user.email });

        console.log(`Hikaye oluşturuluyor: ${childName}, ${theme} (${userId})`);

        const storyParams = { childName, age, gender, theme, companion, specialObject, moral };
        const result = await storyService.generateStory(userId, storyParams);

        res.json({
            success: true,
            story: result.content,
            storyId: result.storyId,
            puzzleEligible: result.puzzleEligible,
            isSaved: result.isSaved,
            message: result.message
        });

    } catch (error) {
        console.error("Story Controller Error:", error);

        // Cooldown hatası
        if (error.message?.startsWith('COOLDOWN:')) {
            const waitSec = error.message.split(':')[1];
            return res.status(429).json({
                error: `Çok hızlı! Lütfen ${waitSec} saniye bekleyin.`,
                code: 'COOLDOWN',
                waitSeconds: parseInt(waitSec)
            });
        }

        // Limit hatası
        if (error.message === 'LIMIT_REACHED') {
            return res.status(403).json({
                error: 'Masal limitine ulaştın! Yeni bir masal oluşturmak için mevcut masallarından birini silmelisin.',
                code: 'LIMIT_REACHED'
            });
        }

        // Quota / Rate Limit hatası (429)
        if (error.status === 429 || error.message?.includes('429') || error.message?.includes('QuotaExceeded')) {
            return res.status(429).json({
                error: 'Sistem şu an çok yoğun. Lütfen 15 saniye sonra tekrar dene.',
                code: 'QUOTA_EXCEEDED'
            });
        }

        res.status(500).json({ error: error.message || 'Bir iç sunucu hatası oluştu.' });
    }
};

// ── Masalı Kitaplığa Kaydet ───────────────────────────────────────────────────
export const saveStory = async (req, res) => {
    try {
        const userId = req.user.uid;
        const storyData = req.body;

        const result = await storyService.saveStoryToLibrary(userId, storyData);
        res.json(result);

    } catch (error) {
        console.error("Save Story Error:", error);
        res.status(500).json({ error: error.message });
    }
};

// ── Kütüphanedeki Masallar ────────────────────────────────────────────────────
export const getMyStories = async (req, res) => {
    try {
        const userId = req.user?.uid;
        if (!userId) return res.status(401).json({ error: "Unauthorized" });

        const stories = await storyService.getUserStories(userId);
        res.json({ success: true, stories });

    } catch (error) {
        console.error("Get My Stories Error:", error);
        res.status(500).json({ error: error.message });
    }
};

// ── Masalı Sil ────────────────────────────────────────────────────────────────
export const deleteStory = async (req, res) => {
    try {
        const userId = req.user?.uid;
        const storyId = req.params.id;

        if (!userId) return res.status(401).json({ error: "Unauthorized" });

        await storyService.deleteStory(storyId, userId);
        res.json({ success: true, message: "Masal silindi" });

    } catch (error) {
        console.error("Delete Story Error:", error);
        res.status(500).json({ error: error.message });
    }
};

// ── Favori Toggling ───────────────────────────────────────────────────────────
export const toggleFavorite = async (req, res) => {
    try {
        const userId = req.user.uid;
        const { storyId, isFavorite } = req.body;

        const result = await storyService.toggleFavorite(userId, storyId, isFavorite);
        res.json(result);

    } catch (error) {
        console.error("Toggle Favorite Error:", error);
        res.status(500).json({ error: error.message });
    }
};

// ── Hazır Masal Okuma Süresi Bildir (Başarım için) ───────────────────────────
export const reportPresetReadTime = async (req, res) => {
    try {
        const userId = req.user.uid;
        const { presetTaleId, timeSpentSeconds } = req.body;

        const result = await gamificationService.checkPresetReadAchievement(
            userId, presetTaleId, timeSpentSeconds
        );

        res.json({ success: true, ...result });

    } catch (error) {
        console.error("Report Preset Read Time Error:", error);
        res.status(500).json({ error: error.message });
    }
};

// ── Kullanıcı Profilini Getir ─────────────────────────────────────────────────
export const getProfile = async (req, res) => {
    try {
        const userId = req.user.uid;
        const profile = await userService.getUserProfile(userId);

        if (!profile) return res.status(404).json({ error: "Profil bulunamadı" });

        const allAchievements = gamificationService.getAllAchievements();
        const completedIds = profile.completedAchievements || [];
        const nextAchievement = gamificationService.getNextAchievement(completedIds);

        res.json({
            success: true,
            profile,
            achievements: allAchievements,
            nextAchievement
        });

    } catch (error) {
        console.error("Get Profile Error:", error);
        res.status(500).json({ error: error.message });
    }
};
