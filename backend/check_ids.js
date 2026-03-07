import { db } from './src/config/firebase.js';
import fs from 'fs';

async function check() {
    const usersSnapshot = await db.collection('users').get();
    const lines = [];
    for (const userDoc of usersSnapshot.docs) {
        const storiesSnapshot = await userDoc.ref.collection('stories').get();
        for (const storyDoc of storiesSnapshot.docs) {
            lines.push(`User ${userDoc.id} | docID: ${storyDoc.id} | title: ${storyDoc.data().content?.title || storyDoc.data().title}`);
        }
    }
    fs.writeFileSync('ids.txt', lines.join('\n'));
}

check().catch(console.error);
