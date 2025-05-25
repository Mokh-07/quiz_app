# Fichiers Audio Vocaux

Ce dossier contient les fichiers audio vocaux pour l'application de quiz.

## Structure recommandée :

### 📢 **Annonces et Instructions :**
- `welcome.mp3` - Message de bienvenue au début du quiz
- `instructions.mp3` - Instructions pour jouer au quiz
- `time_warning.mp3` - Avertissement quand le temps est presque écoulé

### 🎯 **Feedback Vocal :**
- `excellent.mp3` - Félicitations pour une bonne performance
- `good_job.mp3` - Encouragement pour une performance correcte
- `try_again.mp3` - Encouragement pour continuer après une erreur

### 📊 **Résultats :**
- `quiz_complete.mp3` - Annonce de fin de quiz
- `high_score.mp3` - Félicitations pour un score élevé
- `results_ready.mp3` - Annonce que les résultats sont prêts

## Format recommandé :
- **Format** : MP3 ou WAV
- **Qualité** : 44.1 kHz, 16-bit minimum
- **Durée** : 2-5 secondes pour les effets, 5-15 secondes pour les instructions
- **Volume** : Normalisé pour éviter les variations

## Utilisation :
Ces fichiers sont intégrés dans le système AudioService et peuvent être joués pendant l'expérience de quiz pour améliorer l'engagement utilisateur.
