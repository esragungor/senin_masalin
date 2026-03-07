import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import storyRoutes from "./routes/story.routes.js";
import userRoutes from "./routes/user.routes.js";
import ttsRoutes from "./routes/tts.routes.js";
import { admin } from "./config/firebase.js"; // Firebase init check

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Security Middleware
app.use(helmet());

// CORS Config
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(",") : "*",
    methods: ["GET", "POST", "DELETE"],
    credentials: true
}));

// Logger
app.use(morgan("dev"));

// Body Parser
app.use(express.json());

// Debug: Log all incoming requests
app.use((req, res, next) => {
    console.log(`📥 ${req.method} ${req.path} - Headers:`, req.headers);
    next();
});

// Routes
app.use("/api/stories", storyRoutes);
app.use("/api/users", userRoutes);
app.use("/api/tts", ttsRoutes);

// Health Check
app.get("/", (req, res) => {
    res.send({ status: "OK", message: "Senin Masalın Backend API is running! 🚀" });
});

// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: "Sunucu tarafında bir hata oluştu!", details: err.message });
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
    console.log(`Also accessible via http://localhost:${PORT}`);
    console.log(`Android Emulator: http://10.0.2.2:${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Hataları yakalayıp sunucunun sessizce çökmesini önleyelim
process.on('uncaughtException', (err) => {
    console.error('❌ CRITICAL: Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ CRITICAL: Unhandled Rejection at:', promise, 'reason:', reason);
});
