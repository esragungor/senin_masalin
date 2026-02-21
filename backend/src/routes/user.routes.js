import express from "express";
import { getUserProfile } from "../controllers/user.controller.js";
import { authenticate } from "../middlewares/auth.middleware.js";

const router = express.Router();

// GET /api/users/me -> Get current user profile & stats
router.get("/me", authenticate, getUserProfile);

export default router;
