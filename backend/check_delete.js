import storyService from './src/services/story.service.js';

async function check() {
    const userId = 'LYVbVmaOxuRrWSaj0XRDDvBNplX2';
    // Attempt to delete the bottom-most story to be safe
    const storyId = 'ARrh5FayAl'; // From the output earlier

    console.log('Attempting to delete', storyId);
    try {
        await storyService.deleteStory(storyId, userId);
        console.log('Deleted successfully');
    } catch (e) {
        console.log('Error deleting:', e.message);
    }
    process.exit();
}

check().catch(console.error);
