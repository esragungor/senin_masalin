import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

class GeminiService {
  constructor() {
    // API Key'in boş gelmediğinden emin olalım
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY .env dosyasında bulunamadı!");
    }
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    // Modeli burada değil, metod içinde çağırmak bazen daha sağlıklıdır 
    // ama burada kalacaksa ismi 'gemini-1.5-flash' olarak kalsın.
    this.model = this.genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
  }

  async generateStory(params) {
    const { childName, age, gender, theme, companion, moral, magicObject } = params;

    const basePrompt = `
    SEN: Dünyanın en sevilen çocuk masalı yazarı ve uzman bir pedagogsun.
    GÖREVİN: Aşağıdaki bilgilere dayanarak, çocuğun yaşına ({${age}}) tam uygun, büyüleyici, sıcak ve eğitici bir masal kurgulamak.

    --- KAHRAMAN VE DÜNYA ---
    Çocuk: ${childName} (${age} yaşında, ${gender})
    Masal Teması: ${theme}
    Yanındaki Dostu: ${companion || "Sevimli, konuşan bir hayvan"}
    Sihirli Nesne: ${magicObject || "Renkli bir sırt çantası"}
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

    3. GÖRSEL İSTEMİ (Image Prompt): 
       - Her sahne için Pixar/Disney animasyon tarzında, İngilizce, çok detaylı ve renkli görsel tarifleri yaz. 
       - "Cute, magical, vibrant colors, 3d render, soft lighting" gibi kelimeler ekle.
       - Karakterin fiziksel özelliklerini (${gender}, ${age} yaş, saç/göz rengi varsa ekle) her promptta tekrar et.

    --- ÇIKTI FORMATI (SADECE JSON) ---
    Cevabı SADECE şu JSON formatında ver, başka hiçbir yazı yazma:
    {
        "title": "Masalın İlgi Çekici Başlığı",
        "segments": [
            { "order": 1, "text": "...", "imagePrompt": "..." },
            { "order": 2, "text": "...", "imagePrompt": "..." },
            { "order": 3, "text": "...", "imagePrompt": "..." },
            { "order": 4, "text": "...", "imagePrompt": "..." }
        ]
    }
    `;

    try {
      const result = await this.model.generateContent(basePrompt);
      const response = await result.response;
      let text = response.text();

      // JSON'u daha güvenli temizleme
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        text = jsonMatch[0];
      }

      const storyData = JSON.parse(text);

      // Import Fal.ai service dynamically to avoid circular dependency
      const { default: falAiService } = await import('./falai.service.js');

      console.log("📖 Story text generated, now generating images...");

      // Generate images for each segment
      const imagePrompts = storyData.segments.map(seg => seg.imagePrompt);
      const imageUrls = await falAiService.generateImages(imagePrompts);

      // Add image URLs to segments
      storyData.segments.forEach((segment, index) => {
        segment.imageUrl = imageUrls[index];
      });

      console.log("✅ Story complete with images!");
      return storyData;

    } catch (error) {
      console.error("Gemini Detaylı Hata:", error);
      throw error;
    }
  }
}

export default new GeminiService();