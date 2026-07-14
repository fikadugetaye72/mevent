import admin from 'firebase-admin';
import { initializeApp, cert } from 'firebase-admin/app';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

let firebaseAdmin = null;

try {
  // 1. Try to load from the environment variable first (for Railway)
  if (process.env.FIREBASE_CREDENTIALS) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS);
    const app = initializeApp({
      credential: cert(serviceAccount),
    });
    console.log('Firebase Admin SDK initialized successfully from environment variable.');
    firebaseAdmin = app;
  } 
  // 2. Fall back to reading the local file (for local development)
  else {
    const serviceAccountPath = process.env.FIREBASE_CREDENTIALS_PATH || './event-4d26d-firebase-adminsdk-fbsvc-2d10f1044e.json';
    const absoluteKeyPath = path.resolve(serviceAccountPath);
    
    if (fs.existsSync(absoluteKeyPath)) {
      const serviceAccount = JSON.parse(fs.readFileSync(absoluteKeyPath, 'utf8'));
      const app = initializeApp({
        credential: cert(serviceAccount),
      });
      console.log('Firebase Admin SDK initialized successfully from local file.');
      firebaseAdmin = app;
    } else {
      console.warn('Firebase credentials not found in environment variables or local file. Push notifications will be disabled.');
    }
  }
} catch (error) {
  console.error('Failed to initialize Firebase Admin SDK:', error);
}

export default firebaseAdmin;