import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";
dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function listModels() {
    try {
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${process.env.GEMINI_API_KEY}`);
        const data = await response.json();
        console.log("--- SENİN KEYİNİN GÖREBİLDİĞİ MODELLER ---");
        data.models.forEach(m => console.log(m.name));
    } catch (e) {
        console.error("Modeller listelenirken hata oluştu:", e.message);
    }
}

listModels();


