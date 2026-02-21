import * as fal from "@fal-ai/serverless-client";
import dotenv from "dotenv";

dotenv.config();

fal.config({
    credentials: process.env.FAL_API_KEY,
});

class ImageService {
    async generateImage(prompt) {
        try {
            const result = await fal.subscribe("fal-ai/flux/schnell", {
                input: {
                    prompt: prompt,
                    image_size: "landscape_4_3",
                    num_inference_steps: 4,
                    seed: Math.floor(Math.random() * 1000000),
                    enable_safety_checker: true
                },
                logs: true,
                onQueueUpdate: (update) => {
                    if (update.status === "IN_PROGRESS") {
                        update.logs.map((log) => log.message).forEach(console.log);
                    }
                },
            });

            if (result.images && result.images.length > 0) {
                return result.images[0].url;
            } else {
                throw new Error("Görsel oluşturulamadı.");
            }
        } catch (error) {
            console.error("Fal.ai Image Generation Error:", error);
            throw new Error("Görsel oluşturulurken bir hata oluştu.");
        }
    }
}

export default new ImageService();
