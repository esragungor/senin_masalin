import { db } from './src/config/firebase.js';
import fs from 'fs';

async function check() {
    const usersSnapshot = await db.collection('users').get();
    for (const userDoc of usersSnapshot.docs) {
        const storiesSnapshot = await userDoc.ref.collection('stories').get();
        for (const storyDoc of storiesSnapshot.docs) {
            const data = storyDoc.data();
            const lines = [];
            lines.push("FIELDS: " + Object.keys(data).join(", "));
            if (data.content) lines.push("CONTENT FIELDS: " + Object.keys(data.content).join(", "));
            if (data.metadata) lines.push("METADATA FIELDS: " + Object.keys(data.metadata).join(", "));
            fs.writeFileSync('keys.txt', lines.join('\n'));
            process.exit(0);
        }
    }
}

check().catch(console.error);
