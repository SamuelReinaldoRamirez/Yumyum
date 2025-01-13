# Gestion des Vidéos - Bottom Sheet Restaurant

## 1. Composants

### VideoCarousel

- Gestion centralisée des contrôleurs vidéo
- Affichage des miniatures en carousel
- Dimensions : 200px de hauteur
- Responsable de l'initialisation et de la destruction des ressources

### ChewieVideoPlayer

- Affichage de la miniature en mode normal
- Contrôles vidéo en mode plein écran
- Pas de lecture automatique en mode miniature
- Invisible en mode miniature

### FullScreenVideoFeed

- Navigation (verticale) entre les vidéos en plein écran
- Contrôles de lecture complets
- Retour au carousel via bouton retour

## 2. Gestion des Ressources

### Initialisation

- Tous les contrôleurs initialisés dans VideoCarousel
- Miniatures chargées depuis l'URL (.jpg)
- Contrôleurs vidéo créés pour chaque URL (.mp4)

### Cycle de Vie

- Ressources maintenues tant que le carousel est actif
- Destruction complète lors de la fermeture du carousel

## 3. Interactions

### Navigation

- Tap sur miniature → Mode plein écran
- Retour → Mode carousel
- Swipe en plein écran → Vidéo suivante/précédente

### Lecture

- Démarrage automatique en mode plein écran
- Pause lors du retour au carousel
- Synchronisation de la position entre carousel et plein écran

- Lecture automatique de la video ouverte en plein ecran
- Pause automatique des vidéos hors champ
- Reprise de la lecture lors du retour en vue
- pause automatique quand on quitte le mode plein écran
- pause automatique quand on quitte l’application pour naviguer sur d’autres applications