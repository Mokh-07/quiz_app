// Configuration Firebase pour le web
// REMPLACEZ cette configuration par la vôtre depuis Firebase Console

const firebaseConfig = {
  // 🔥 CONFIGURATION FIREBASE RÉELLE 🔥
  apiKey: "AIzaSyAXQNRP6ubidjX7X7W3V37SN_GdP5qNxnw",
  authDomain: "quiz-app-firebase-5d348.firebaseapp.com",
  projectId: "quiz-app-firebase-5d348",
  storageBucket: "quiz-app-firebase-5d348.firebasestorage.app",
  messagingSenderId: "202628820831",
  appId: "1:202628820831:web:ec4de7df7acc9739a410ea",
  measurementId: "G-SME68GQZ8P"
};

// Initialiser Firebase
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
import { getAuth } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Rendre disponible globalement
window.firebaseConfig = firebaseConfig;
window.firebaseApp = app;
window.firebaseAuth = auth;
