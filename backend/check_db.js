import { db } from './src/config/firebase.js';

async function check() {
    const usersSnapshot = await db.collection('users').get();
    for (const userDoc of usersSnapshot.docs) {
        const storiesSnapshot = await userDoc.ref.collection('stories').get();
        for (const storyDoc of storiesSnapshot.docs) {
            console.log(JSON.stringify(storyDoc.data(), null, 2));
            process.exit(0); // Exit right after printing 1 story successfully
        }
    }
}

check().catch(console.error);
