import { admin, db } from '../config/firebase.js';
import axios from 'axios';

class StorageService {
    /**
     * Download image from URL and upload to Firebase Storage
     * @param {string} imageUrl - Source image URL (from Fal.ai)
     * @param {string} storyId - Story ID for folder organization
     * @param {number} pageIndex - Page number
     * @returns {Promise<string>} - Firebase Storage public URL
     */
    async uploadImageToFirebase(imageUrl, userId, storyId, pageIndex) {
        try {
            console.log(`📤 Uploading image ${pageIndex} to Firebase Storage...`);

            // 1. Download image from Fal.ai URL
            const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
            const imageBuffer = Buffer.from(response.data);

            // 2. Upload to Firebase Storage with hierarchical path
            const bucket = admin.storage().bucket();
            const fileName = `users/${userId}/stories/${storyId}/images/page_${pageIndex}.png`;
            const file = bucket.file(fileName);

            await file.save(imageBuffer, {
                metadata: {
                    contentType: 'image/png',
                    cacheControl: 'public, max-age=31536000', // Cache for 1 year
                },
            });

            // 3. Make file publicly accessible
            await file.makePublic();

            // 4. Get public URL
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

            console.log(`✅ Image ${pageIndex} uploaded to users/${userId}/stories/${storyId}/images/`);
            return publicUrl;

        } catch (error) {
            console.error(`❌ Error uploading image ${pageIndex}:`, error);
            // Return original URL as fallback
            return imageUrl;
        }
    }

    /**
     * Upload all story images to Firebase Storage
     * @param {Array} segments - Story segments with imageUrl
     * @param {string} userId - User ID
     * @param {string} storyId - Story ID
     * @returns {Promise<Array>} - Segments with Firebase URLs
     */
    async uploadStoryImages(segments, userId, storyId) {
        try {
            console.log(`📤 Uploading ${segments.length} images to Firebase...`);

            const uploadPromises = segments.map((segment, index) =>
                this.uploadImageToFirebase(segment.imageUrl, userId, storyId, index)
            );

            const firebaseUrls = await Promise.all(uploadPromises);

            // Update segments with Firebase URLs
            segments.forEach((segment, index) => {
                segment.imageUrl = firebaseUrls[index];
            });

            console.log(`✅ All images uploaded to Firebase!`);
            return segments;

        } catch (error) {
            console.error('❌ Error uploading story images:', error);
            return segments;
        }
    }

    /**
     * Delete all images for a story
     * @param {string} userId - User ID
     * @param {string} storyId - Story ID
     */
    async deleteStoryImages(userId, storyId) {
        try {
            const bucket = admin.storage().bucket();
            await bucket.deleteFiles({
                prefix: `users/${userId}/stories/${storyId}/`
            });
            console.log(`🗑️ Deleted all images for story ${storyId}`);
        } catch (error) {
            console.error('❌ Error deleting story images:', error);
        }
    }
}

export default new StorageService();
