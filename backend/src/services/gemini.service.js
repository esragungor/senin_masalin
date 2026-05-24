import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

// 503 veya 429 hatalarında yeniden deneme yardımcısı
async function retryWithBackoff(fn, maxRetries = 2, delayMs = 3000) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err) {
      const isRetryable = err?.status === 503 || err?.status === 429;
      if (isRetryable && attempt < maxRetries) {
        console.warn(`⚠️ Gemini ${err.status} hatası – ${delayMs / 1000}s sonra tekrar deneniyor... (${attempt + 1}/${maxRetries})`);
        await new Promise(r => setTimeout(r, delayMs));
      } else {
        throw err;
      }
    }
  }
}

class GeminiService {
  constructor() {
    // API Key'in boş gelmediğinden emin olalım
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY .env dosyasında bulunamadı!");
    }
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    // Birincil model
    this.primaryModel = this.genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    // 503 durumunda yedek model
    this.fallbackModel = this.genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    // Geriye dönük uyumluluk
    this.model = this.primaryModel;
  }

  async generateStory(params) {
    const { childName, age, gender, theme, companion, moral, specialObject } = params;

    const basePrompt = `
    SEN: Dünyanın en sevilen çocuk masalı yazarı ve uzman bir pedagogsun.
    GÖREVİN: Aşağıdaki bilgilere dayanarak, çocuğun yaşına (${age}) tam uygun, büyüleyici, sıcak ve eğitici bir masal kurgulamak.

    --- KAHRAMAN VE DÜNYA ---
    Çocuk: ${childName} (${age} yaşında, ${gender})
    Masal Teması: ${theme}
    Yanındaki Dostu: ${companion || "Sevimli, konuşan bir hayvan"}
    Sihirli Nesne: ${specialObject || "Renkli bir sırt çantası"}
    Verilecek Ders: ${moral || "Sevgi, dostluk ve cesaret"}

    --- YAZIM KURALLARI (ÇOK ÖNEMLİ) ---
    1. DİL VE TON: 
       - Çocuğun yaşına (${age}) dikkat et! 
       - Eğer yaş 3-5 ise: Çok basit, kısa cümleler, yansıma sesler (pat pat, şırıl şırıl), tekrarlar ve neşeli bir ton kullan.
       - Eğer yaş 6-9 ise: Biraz daha macera dolu, merak uyandırıcı bir dil kullan.
       - Masal, "Bir varmış, bir yokmuş..." veya benzeri sıcak bir girişle başlasın.
    
    2. KURGU (4 Sahne):
       - Sahne 1 (Giriş): Kahramanı ve yaşadığı sihirli dünyayı tanıt. Sihirli nesne ile olan bağını göster.
       - Sahne 2 (Macera): Maceraya çıkış. Yan karakter ile karşılaşma ve eğlenceli bir diyalog.
       - Sahne 3 (Olay): Küçük bir sorun veya heyecanlı bir an yaşansın. Verilecek ders burada işlensin.
       - Sahne 4 (Mutlu Son): Sorun çözülsün, kahramanımız evine/güvenli yerine dönsün ve dersini almış olsun.

    --- ÇIKTI FORMATI (SADECE JSON) ---
    Cevabı SADECE şu JSON formatında ver, başka hiçbir yazı yazma:
    {
        "title": "Masalın İlgi Çekici Başlığı",
        "segments": [
            { "order": 1, "text": "..." },
            { "order": 2, "text": "..." },
            { "order": 3, "text": "..." },
            { "order": 4, "text": "..." }
        ]
    }
    `;

    // Metni üret: önce 2.5-flash dene, 503 devam ederse 1.5-flash'a geç
    let rawText;
    try {
      rawText = await retryWithBackoff(async () => {
        const result = await this.primaryModel.generateContent(basePrompt);
        return result.response.text();
      });
    } catch (primaryErr) {
      if (primaryErr?.status === 503 || primaryErr?.status === 429) {
        console.warn("⚠️ gemini-2.5-flash erişilemiyor, gemini-1.5-flash'a geçiliyor...");
        const result = await this.fallbackModel.generateContent(basePrompt);
        rawText = result.response.text();
      } else {
        console.error("Gemini Detaylı Hata:", primaryErr);
        throw primaryErr;
      }
    }

    // JSON'u daha güvenli temizleme (Markdown kod blokları vs.)
    let text = rawText.replace(/```json/g, "").replace(/```/g, "").trim();
    const startIndex = text.indexOf('{');
    const endIndex = text.lastIndexOf('}');
    if (startIndex !== -1 && endIndex !== -1) {
      text = text.slice(startIndex, endIndex + 1);
    }

    const storyData = JSON.parse(text);

    console.log("📖 Story text generated, now generating images...");

    // Resim üretimini dene, hata olursa masalı yine de döndür
    try {
      const { default: falAiService } = await import('./falai.service.js');

      const imagePrompts = storyData.segments.map(seg => {
        return `Pixar/Disney 3D animation style, very cute, high quality, colorful, magical, vibrant colors, soft lighting, 8k resolution, children's book illustration. Scene description: ${seg.text}`;
      });

      const imageUrls = await falAiService.generateImages(imagePrompts);

      storyData.segments.forEach((segment, index) => {
        segment.imageUrl = imageUrls[index];
      });

      console.log("✅ Story complete with images!");
    } catch (imageError) {
      console.error("⚠️ Resim üretimi başarısız, masalı resimsiz döndürüyoruz:", imageError.message);
      // Placeholder resim URL'si ata
      storyData.segments.forEach((segment) => {
        segment.imageUrl = null;
      });
    }
    return storyData;
  }
}

export default new GeminiService();