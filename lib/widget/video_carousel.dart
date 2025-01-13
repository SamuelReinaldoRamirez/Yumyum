// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:yummap/managers/video_player_manager.dart';
import 'package:yummap/widget/full_screen_video_feed.dart'; // Import de FullScreenVideoFeed
import 'package:yummap/helper/bottom_sheet_helper.dart'; // Assurez-vous que cette ligne est présente

class VideoCarousel extends StatefulWidget {
  final List<String> videos;
  final dynamic restaurant; // Ajouter le restaurant ici

  const VideoCarousel({
    Key? key,
    required this.videos,
    required this.restaurant, // Ajouter le restaurant ici
  }) : super(key: key);

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  final _videoManager = VideoPlayerManager();
  late List<String> _videos;
  int _currentIndex = 0;
  bool _isFullScreen = false;
  int _currentFullScreenIndex =
      0; // Pour suivre l'index de la vidéo en plein écran
  bool _thumbnailsLoaded =
      false; // Nouvel état pour suivre le chargement des miniatures
  final Map<String, bool> _loadedThumbnails =
      {}; // Pour suivre les miniatures chargées

  @override
  void initState() {
    super.initState();
    _videos = widget.videos;
    _loadThumbnails(); // Charger les miniatures d'abord
  }

  Future<void> _loadThumbnails() async {
    // Initialiser toutes les miniatures comme non chargées
    for (String videoUrl in _videos) {
      _loadedThumbnails[videoUrl] = false;
    }
    setState(() {
      _thumbnailsLoaded = true; // Permettre l'affichage du carrousel
    });

    // Initialiser les contrôleurs vidéo en arrière-plan
    _videoManager.initializeControllers(_videos);
  }

  void _openFullScreenVideo(int index) {
    // Pause la vidéo actuelle avant d'ouvrir le plein écran
    if (_videos.isNotEmpty) {
      _videoManager.pause(_videos[_currentIndex]); // Pause la vidéo actuelle
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        maintainState: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenVideoFeed(
          videos: _videos,
          initialIndex: index,
          onExit: _exitFullScreen,
          onNavigateToDetails: () {
              _navigateToDetails(); // Appeler la méthode de navigation
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Début de l'animation
          const end = Offset.zero; // Fin de l'animation
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false; // Masquer le plein écran
    });
    Navigator.of(context).pop();
  }

  void _navigateToDetails() {
    BottomSheetHelper.navigateToRestaurantDetails(context, widget.restaurant);
  }

  Widget _buildCarouselItem(int index) {
    final videoUrl = _videos[index];
    final thumbnailUrl = videoUrl.replaceFirst('.mp4', '.jpg');

    return GestureDetector(
      onTap: () => _openFullScreenVideo(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            // Centrer le contenu
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.35, // Ajuster la hauteur
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame != null) {
                      _loadedThumbnails[videoUrl] = true;
                    }
                    return child;
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_thumbnailsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isFullScreen) {
      return FullScreenVideoFeed(
        videos: _videos,
        initialIndex: _currentFullScreenIndex,
        onExit: _exitFullScreen, // Passer la fonction onExit
        onNavigateToDetails: () {
              _navigateToDetails(); // Appeler la méthode de navigation
          },
      );
    }

    return CarouselSlider.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index, realIndex) => _buildCarouselItem(index),
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.24, // Ajuster la hauteur
        viewportFraction:
            0.4, // Ajuster la fraction de vue pour réduire l'espace
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
        initialPage: 1,
        scrollDirection: Axis.horizontal,
        autoPlay: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class Video {
  final String url;
  final String thumbnailUrl;

  Video({required this.url, required this.thumbnailUrl});
}
