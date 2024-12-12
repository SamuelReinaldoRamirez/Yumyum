# YumMap - La carte aux trésors du Paris culinaire 🗺️🍽️

## Description
YumMap est une application mobile développée avec Flutter qui permet aux utilisateurs de découvrir les meilleurs restaurants de Paris. L'application offre une expérience interactive avec une carte personnalisée et des fonctionnalités de géolocalisation pour trouver facilement les trésors culinaires de la capitale française.

## Version
Version actuelle : 3.1.0

## Technologies Utilisées
- Flutter SDK (>=3.2.6 <4.0.0)
- Dart
- Google Maps (flutter_map)
- Mixpanel pour l'analytics
- Support multilingue (easy_localization)

## Fonctionnalités Principales
- 🗺️ Carte interactive personnalisée
- 📍 Géolocalisation des restaurants
- ⭐ Système de notation
- 🌍 Support multilingue
- 📱 Interface utilisateur moderne et intuitive
- 🎯 Clustering des marqueurs sur la carte
- 📹 Support vidéo intégré
- 🔒 Stockage sécurisé des données

## Structure du Projet
```
lib/
├── constant/      # Constants et configurations
├── helper/        # Classes utilitaires
├── model/         # Modèles de données
├── page/          # Pages de l'application
├── service/       # Services (API, etc.)
├── widget/        # Widgets réutilisables
└── main.dart      # Point d'entrée de l'application
```

## Dépendances Principales
- `flutter_map`: Affichage de la carte
- `geolocator`: Géolocalisation
- `mixpanel_flutter`: Analytics
- `flutter_secure_storage`: Stockage sécurisé
- `easy_localization`: Internationalisation

## Configuration Requise
- Flutter SDK >=3.2.6
- iOS 11.0 ou supérieur
- Android 5.0 (API 21) ou supérieur

## Installation
1. Cloner le repository
2. Installer les dépendances : `flutter pub get`
3. Lancer l'application : `flutter run`

## Ressources
L'application utilise :
- Police personnalisée : Poppins et Sifonn
- Assets : Images, fichiers de traduction et configuration de carte personnalisée

## Plateformes Supportées
- iOS
- Android
- Web
- macOS
- Linux
- Windows
