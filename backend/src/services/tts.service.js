import textToSpeech from "@google-cloud/text-to-speech";
import fs from "fs";
import util from "util";
import dotenv from "dotenv";

dotenv.config();

class TTSService {
    constructor() {
        this.client = new textToSpeech.TextToSpeechClient();
    }

    async generateAudio(text, gender = "FEMALE") {
        const request = {
            input: { text: text },
            // Voice selection: tr-TR-Neural2-A (Female) or B (Male) are good options
            voice: {
                languageCode: "tr-TR",
                name: gender === "MALE" ? "tr-TR-Wavenet-B" : "tr-TR-Wavenet-A",
                ssmlGender: gender
            },
            audioConfig: { audioEncoding: "MP3" },
        };

        try {
            const [response] = await this.client.synthesizeSpeech(request);
            return response.audioContent; // Returns Buffer
        } catch (error) {
            console.error("Google Cloud TTS Error:", error);
            throw new Error("Ses dosyası oluşturulurken bir hata oluştu.");
        }
    }
}

export default new TTSService();
