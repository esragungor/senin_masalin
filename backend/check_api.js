import storyService from './src/services/story.service.js';
import fs from 'fs';

async function check() {
    const stories = await storyService.getUserStories('LYVbVmaOxuRrWSaj0XRDDvBNplX2');
    fs.writeFileSync('api_output.txt', JSON.stringify(stories, null, 2), 'utf8');
    process.exit();
}

check().catch(console.error);
