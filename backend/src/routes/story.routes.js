import express from "express";
import {
    createStory,
    getMyStories,
    deleteStory,
    saveStory,
    toggleFavorite,
    reportPresetReadTime,
    getProfile
} from "../controllers/story.controller.js";
import rateLimit from "express-rate-limit";
import { authenticate } from "../middlewares/auth.middleware.js";

const router = express.Router();

// Spam önleme: 1 dakikada 3'ten fazla masal üretme isteği engellenir
const createStoryLimiter = rateLimit({
    windowMs: 60 * 1000,  // 1 dakika
    max: 3,
    message: { error: "Çok fazla istek gönderdiniz, lütfen biraz bekleyin.", code: "RATE_LIMIT" }
});

// ── Masal Endpoint'leri ────────────────────────────────────────────────────────
router.post("/generate", authenticate, createStoryLimiter, createStory);
router.post("/save", authenticate, saveStory);
router.get("/my-stories", authenticate, getMyStories);
router.delete("/:id", authenticate, deleteStory);
router.post("/favorite", authenticate, toggleFavorite);

// ── Hazır Masal (Preset) ──────────────────────────────────────────────────────
router.post("/preset-read-time", authenticate, reportPresetReadTime); // Başarım için süre bildir

// ── Profil ───────────────────────────────────────────────────────────────────
router.get("/profile", authenticate, getProfile);

export default router;
