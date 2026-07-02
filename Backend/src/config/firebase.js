import admin from 'firebase-admin';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

const serviceAccountPath = process.env.FIREBASE_CREDENTIALS_PATH || './event-4d26d-firebase-adminsdk-fbsvc-2d10f1044e.json';
const absoluteKeyPath = path.resolve(serviceAccountPath);

let firebaseAdmin = null;

try {
  if (fs.existsSync(absoluteKeyPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(absoluteKeyPath, 'utf8'));
    const app = admin.initializeApp({
      credential: admin.cert(serviceAccount),
    });
    console.log('Firebase Admin SDK initialized successfully.');
    firebaseAdmin = app;
  } else {
    console.warn(`Firebase credentials file not found at ${absoluteKeyPath}. Push notifications will be disabled.`);
  }
} catch (error) {
  console.error('Failed to initialize Firebase Admin SDK:', error);
}

export default firebaseAdmin;
