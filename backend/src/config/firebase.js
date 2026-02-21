import admin from "firebase-admin";
import dotenv from "dotenv";

dotenv.config();

// Read service account from env or file
// Since we have the file path in .env for other tools but likely not for this specific usage if we want to use the JSON object directly or path.
// However, standard practice with firebase-admin is to use cert().

import serviceAccount from "./firebase-service-account.json" with { type: "json" };

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
        projectId: process.env.FIREBASE_PROJECT_ID
    });
}

const db = admin.firestore();
const auth = admin.auth();
const bucket = admin.storage().bucket();

export { admin, db, auth, bucket };
