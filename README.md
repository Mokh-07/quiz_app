# Quiz App 🧠

Une application mobile Flutter interactive pour jouer à des quiz avec des questions en temps réel.

## 📱 Fonctionnalités

### ✅ Fonctionnalités de base (Implémentées)
- **Écran d'accueil** avec menu principal intuitif
- **Configuration du quiz** : choix de catégorie, difficulté et nombre de questions
- **Questions en temps réel** récupérées depuis l'API OpenTDB
- **Interface de quiz** interactive avec réactions visuelles
- **Système de score** et affichage des résultats détaillés
- **Historique des quiz** avec statistiques
- **Écran "À propos"** avec informations sur l'application

### 🚀 Fonctionnalités futures
- Système de notifications push
- Mode clair/sombre
- Effets sonores et vibrations
- Support multilingue (Fr-En-Ar)
- Écran de paramètres
- Classement des meilleurs scores

## 🛠️ Technologies utilisées

- **Flutter** - Framework de développement cross-platform
- **Dart** - Langage de programmation
- **Provider** - Gestion d'état
- **HTTP** - Requêtes API
- **SharedPreferences** - Stockage local
- **HTML** - Décodage des questions

## 🌐 API

L'application utilise l'**Open Trivia Database (OpenTDB)** :
- URL : https://opentdb.com
- API gratuite et collaborative
- Questions de culture générale variées
- Différentes catégories et niveaux de difficulté

## 📁 Structure du projet

```
lib/
├── models/          # Modèles de données
│   ├── question.dart
│   ├── category.dart
│   └── quiz_result.dart
├── services/        # Services et logique métier
│   ├── api_service.dart
│   ├── storage_service.dart
│   └── quiz_provider.dart
├── screens/         # Écrans de l'application
│   ├── home_screen.dart
│   ├── quiz_setup_screen.dart
│   ├── quiz_screen.dart
│   ├── quiz_result_screen.dart
│   ├── history_screen.dart
│   └── about_screen.dart
├── widgets/         # Composants réutilisables
│   ├── custom_button.dart
│   └── app_card.dart
├── utils/           # Utilitaires et constantes
│   └── constants.dart
└── main.dart        # Point d'entrée de l'application
```

## 🚀 Installation et lancement

### Prérequis
- Flutter SDK (version 3.7.2 ou supérieure)
- Dart SDK
- Un émulateur ou appareil physique

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone <url-du-repo>
   cd quiz_app
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📱 Utilisation

1. **Écran d'accueil** : Choisissez "Commencer un quiz" pour démarrer
2. **Configuration** : Sélectionnez la catégorie, difficulté et nombre de questions
3. **Quiz** : Répondez aux questions en sélectionnant une réponse
4. **Résultats** : Consultez votre score et les bonnes réponses
5. **Historique** : Suivez vos performances dans l'onglet historique

## 🎨 Design

L'application utilise Material Design 3 avec :
- **Couleur principale** : Bleu (#2196F3)
- **Interface moderne** avec animations fluides
- **Cartes et boutons** avec coins arrondis
- **Feedback visuel** pour les interactions

## 🔧 Configuration

### Dépendances principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1      # Gestion d'état
  http: ^1.1.0          # Requêtes HTTP
  html: ^0.15.4         # Décodage HTML
  shared_preferences: ^2.2.2  # Stockage local
```

## 📊 Fonctionnement de l'API

L'application communique avec OpenTDB pour :
- Récupérer la liste des catégories disponibles
- Obtenir des questions selon les critères sélectionnés
- Gérer les erreurs de connexion et les réponses vides

## 🐛 Gestion des erreurs

- **Pas de connexion internet** : Message d'erreur avec option de réessai
- **API indisponible** : Gestion gracieuse avec feedback utilisateur
- **Questions insuffisantes** : Notification et suggestions alternatives

## 🔮 Roadmap

### Version 1.1
- [ ] Mode sombre/clair
- [ ] Effets sonores
- [ ] Vibrations

### Version 1.2
- [ ] Support multilingue
- [ ] Notifications push
- [ ] Paramètres avancés

### Version 2.0
- [ ] Classements en ligne
- [ ] Quiz personnalisés
- [ ] Mode multijoueur

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Développeur

Développé avec ❤️ en utilisant Flutter
