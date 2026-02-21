import * as fal from "@fal-ai/serverless-client";
import dotenv from "dotenv";

dotenv.config();

class FalAiService {
    constructor() {
        if (!process.env.FAL_API_KEY) {
            throw new Error("FAL_API_KEY not found in .env file!");
        }

        // Configure Fal.ai client
        fal.config({
            credentials: process.env.FAL_API_KEY
        });
    }

    /**
     * Generate an image using Fal.ai FLUX model
     * @param {string} prompt - Image generation prompt
     * @returns {Promise<string>} - Image URL
     */
    async generateImage(prompt) {
        try {
            console.log("🎨 Fal.ai: Generating image for prompt:", prompt.substring(0, 100) + "...");

            const result = await fal.subscribe("fal-ai/flux/schnell", {
                input: {
                    prompt: prompt,
                    image_size: "square", // 512x512 (cheaper than square_hd 1024x1024)
                    num_inference_steps: 4, // Fast mode (schnell)
                    num_images: 1,
                    enable_safety_checker: true
                },
                logs: true,
                onQueueUpdate: (update) => {
                    if (update.status === "IN_PROGRESS") {
                        console.log("🎨 Fal.ai: Image generation in progress...");
                    }
                }
            });

            console.log("🔍 Fal.ai Full Result:", JSON.stringify(result, null, 2));

            // Fal.ai returns images directly in result, not in result.data
            if (result.images && result.images.length > 0) {
                const imageUrl = result.images[0].url;
                console.log("✅ Fal.ai: Image generated successfully!");
                console.log("🔗 Image URL:", imageUrl);
                return imageUrl;
            } else {
                console.error("❌ Fal.ai: No images in result");
                console.error("Result:", result);
                throw new Error("No image returned from Fal.ai");
            }

        } catch (error) {
            console.error("❌ Fal.ai Error:", error);
            console.error("Error details:", error.message);
            throw new Error(`Fal.ai image generation failed: ${error.message}`);
        }
    }

    /**
     * Generate multiple images in parallel
     * @param {Array<string>} prompts - Array of image prompts
     * @returns {Promise<Array<string>>} - Array of image URLs
     */
    async generateImages(prompts) {
        try {
            console.log(`🎨 Fal.ai: Generating ${prompts.length} images...`);

            const imagePromises = prompts.map(prompt => this.generateImage(prompt));
            const imageUrls = await Promise.all(imagePromises);

            console.log(`✅ Fal.ai: All ${imageUrls.length} images generated!`);
            return imageUrls;

        } catch (error) {
            console.error("❌ Fal.ai Batch Error:", error);
            throw error;
        }
    }
}

export default new FalAiService();
