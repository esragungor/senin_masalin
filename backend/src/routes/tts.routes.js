import express from 'express';
import { authenticate } from '../middlewares/auth.middleware.js';
import fetch from 'node-fetch';

const router = express.Router();

/**
 * POST /api/tts/synthesize
 * Body: { text: "..." }
 * Returns: audio/mpeg binary
 */
router.post('/synthesize', authenticate, async (req, res) => {
    try {
        const { text } = req.body;
        if (!text) return res.status(400).json({ error: 'text gerekli' });

        const apiKey = process.env.GOOGLE_TTS_API_KEY;
        const url = `https://texttospeech.googleapis.com/v1/text:synthesize?key=${apiKey}`;

        const ttsRes = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                input: { text },
                voice: {
                    languageCode: 'tr-TR',
                    name: 'tr-TR-Wavenet-A', // Çok daha kaliteli, profesyonel ses
                    ssmlGender: 'FEMALE'
                },
                audioConfig: {
                    audioEncoding: 'MP3',
                    speakingRate: 1.0,   // Normal hız
                    pitch: 0.0           // Normal perde
                }
            })
        });

        const json = await ttsRes.json();

        if (!json.audioContent) {
            console.error('TTS Error:', json);
            return res.status(500).json({ error: 'Ses üretilemedi', detail: json });
        }

        // Base64 → Buffer → MP3 olarak gönder
        const audioBuffer = Buffer.from(json.audioContent, 'base64');
        res.set('Content-Type', 'audio/mpeg');
        res.send(audioBuffer);

    } catch (err) {
        console.error('TTS Route Error:', err);
        res.status(500).json({ error: err.message });
    }
});

export default router;
