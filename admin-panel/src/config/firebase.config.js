/**
 * Firebase Configuration for Admin Panel (Web)
 * 
 * Project: falla-6b4f1
 * Storage: falla-6b4f1.firebasestorage.app
 */

import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: "AIzaSyBiWlFCLzubc00UCHYGoADMYTn6cQOOqbk",
  authDomain: "falla-6b4f1.firebaseapp.com",
  projectId: "falla-6b4f1",
  storageBucket: "falla-6b4f1.firebasestorage.app",
  messagingSenderId: "916591463999",
  appId: "1:916591463999:web:ec74130e286d1c6ac1328a",
  measurementId: "G-T81WWJ2XHD"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;

// Firestore Collections
export const COLLECTIONS = {
  USERS: 'users',
  READINGS: 'readings',
  TAROT_CARDS: 'tarot_cards',
  FORTUNE_TELLERS: 'fortune_tellers',
  HOROSCOPES: 'horoscopes',
  IP_ADDRESSES: 'ip_addresses',
  ADMINS: 'admins',
  CHATS: 'chats',
  MATCHES: 'matches',
  REPORTS: 'reports',
};

// Subcollections
export const SUBCOLLECTIONS = {
  FORTUNES: 'fortunes',
  TESTS: 'tests',
  TEST_RESULTS: 'test_results',
  QUIZ_TEST_RESULTS: 'quiz_test_results',
  SPINS: 'spins',
  KARMA_TRANSACTIONS: 'karma_transactions',
  DAILY_ACTIVITIES: 'daily_activities',
  DREAM_DRAWS: 'dream_draws',
};

// Fortune Types
export const FORTUNE_TYPES = {
  TAROT: 'tarot',
  COFFEE: 'coffee',
  PALM: 'palm',
  KATINA: 'katina',
  WATER: 'water',
  ASTROLOGY: 'astrology',
  DREAM: 'dream',
  DAILY: 'daily',
};

// Test Types
export const TEST_TYPES = {
  LOVE: 'love',
  RELATIONSHIP: 'relationship',
  DESTINY: 'destiny',
  PERSONALITY: 'personality',
  QUIZ: 'quiz',
};
