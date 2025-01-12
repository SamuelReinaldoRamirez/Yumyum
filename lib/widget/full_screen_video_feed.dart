import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:yummap/widget/chewie_video_player.dart';
import 'package:yummap/widget/custom_video_controls.dart';

class FullScreenVideoFeed extends StatefulWidget {
  final List<ChewieController> controllers;
  final int initialIndex;

  const FullScreenVideoFeed({
    super.key,
    required this.controllers,
    required this.initialIndex,
  });

  @override
  State<FullScreenVideoFeed> createState() => _FullScreenVideoFeedState();
}

class _FullScreenVideoFeedState extends State<FullScreenVideoFeed> {
  late PageController _pageController;
  Map<int, ChewieController> _chewieControllers = {};
  int _activeIndex = -1;
  bool _isInitialized = false;
  bool _isLoadingActiveVideo = false;
  VideoPlayerController? _videoPlayerController;

  static const int MAX_CACHE_SIZE =
      15; // Par exemple, garder 15 vidéos en cache maximum
  final Map<int, DateTime> _lastAccessTime =
      {}; // Map pour stocker les timestamps de dernière utilisation

  static const int MAX_THUMBNAIL_CACHE_SIZE =
      15; // Taille maximale du cache des miniatures
  final Map<int, String> _thumbnailCache = {}; // Cache pour les miniatures
  final Map<int, DateTime> _thumbnailAccessTime =
      {}; // Timestamps pour les miniatures

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeActiveVideo();
    _loadThumbnails();
  }

  void _loadThumbnails() {
    for (int i = 0; i < widget.controllers.length; i++) {
      final thumbnailUrl = getThumbnailUrl(widget.controllers[i].videoPlayerController.dataSource);
      _thumbnailCache[i] = thumbnailUrl; // Stocker la miniature dans le cache
      _thumbnailAccessTime[i] = DateTime.now(); // Enregistrer le timestamp
    }
  }

  String getThumbnailUrl(String videoLink) {
    // Logique pour générer l'URL de la miniature à partir du lien vidéo
    return videoLink.replaceFirst('.mp4', '_thumbnail.jpg'); // Exemple
  }

  void _cleanupOldThumbnails() {
    if (_thumbnailCache.length <= MAX_THUMBNAIL_CACHE_SIZE) return;

    // Trier les miniatures par timestamp d'accès
    final sortedIndices = _thumbnailAccessTime.keys.toList()
      ..sort((a, b) =>
          _thumbnailAccessTime[a]!.compareTo(_thumbnailAccessTime[b]!));

    // Supprimer les miniatures les plus anciennes
    for (var i = 0; i < sortedIndices.length - MAX_THUMBNAIL_CACHE_SIZE; i++) {
      final index = sortedIndices[i];
      _thumbnailCache.remove(index);
      _thumbnailAccessTime.remove(index);
    }
  }

  Future<void> _initializeActiveVideo() async {
    if (!mounted) return;

    setState(() {
      _isLoadingActiveVideo = true;
    });

    try {
      _videoPlayerController =
          VideoPlayerController.network(widget.controllers[_activeIndex].videoPlayerController.dataSource);
      await _videoPlayerController?.initialize();

      // Créer le ChewieController avec le placeholder
      _chewieControllers[_activeIndex] = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 9 / 16,
        autoPlay: true,
        looping: true,
        placeholder: Image.network(
          _thumbnailCache[_activeIndex] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
          ),
        ),
        customControls: CustomVideoControls(
          videoPlayerController: _videoPlayerController!,
          showPlayPause: true,
          showFullScreenButton: false,
          onToggleFullScreen: () => Navigator.pop(context),
        ),
      );

      _lastAccessTime[_activeIndex] =
          DateTime.now(); // Enregistrer le timestamp

      setState(() {
        _isInitialized = true;
        _isLoadingActiveVideo = false;
      });
    } catch (e) {
      print('Erreur lors de l\'initialisation de la vidéo active: $e');
      setState(() {
        _isLoadingActiveVideo = false;
      });
    }
  }

  Future<void> _initializeVideoAtIndex(int index) async {
    if (!mounted) return;
    if (_chewieControllers[index] != null) {
      // Mettre à jour le timestamp d'accès
      _lastAccessTime[index] = DateTime.now();
      return;
    }

    try {
      final videoController =
          VideoPlayerController.network(widget.controllers[index].videoPlayerController.dataSource);
      await videoController.initialize();

      if (!mounted) return;

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        aspectRatio: 9 / 16,
        autoPlay: index == _activeIndex, // Autoplay uniquement pour la vidéo active
        looping: true,
        customControls: CustomVideoControls(
          videoPlayerController: videoController,
          showPlayPause: true,
          showFullScreenButton: false,
          onToggleFullScreen: () => Navigator.pop(context),
        ),
      );

      _chewieControllers[index] = chewieController;
      _lastAccessTime[index] = DateTime.now(); // Enregistrer le timestamp

      // Si on dépasse la taille maximale du cache, nettoyer les plus anciennes vidéos
      if (_chewieControllers.length > MAX_CACHE_SIZE) {
        _cleanupOldestVideos();
      }

      setState(() {});
    } catch (e) {
      print('Erreur lors de l\'initialisation de la vidéo $index: $e');
    }
  }

  void _cleanupOldestVideos() {
    if (_chewieControllers.length <= MAX_CACHE_SIZE) return;

    // Trier les vidéos par timestamp d'accès
    final sortedIndices = _lastAccessTime.keys.toList()
      ..sort((a, b) => _lastAccessTime[a]!.compareTo(_lastAccessTime[b]!));

    // Garder les vidéos les plus récemment utilisées
    for (var i = 0; i < sortedIndices.length - MAX_CACHE_SIZE; i++) {
      final index = sortedIndices[i];
      // Ne pas supprimer les vidéos proches de l'index actif
      if ((index - _activeIndex).abs() <= 3) continue;

      _cleanupControllerAtIndex(index);
      _lastAccessTime.remove(index);
    }
  }

  void _cleanupControllerAtIndex(int index) {
    _chewieControllers[index]?.dispose();
    _chewieControllers.remove(index);
  }

  Future<void> _handlePageChange(int newIndex) async {
    if (!mounted) return;

    // Mettre à jour le timestamp d'accès pour la nouvelle vidéo
    _lastAccessTime[newIndex] = DateTime.now();

    if (_chewieControllers[_activeIndex]
            ?.videoPlayerController
            .value
            .isPlaying ??
        false) {
      await _chewieControllers[_activeIndex]?.pause();
    }

    setState(() {
      _activeIndex = newIndex;
    });

    if (_chewieControllers[newIndex] == null) {
      await _initializeVideoAtIndex(newIndex);
    } else {
      await _chewieControllers[newIndex]?.play();
    }
  }

  Future<void> _pauseAllVideos() async {
    for (final controller in _chewieControllers.values) {
      if (controller.videoPlayerController.value.isPlaying) {
        await controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _pauseAllVideos();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.controllers.length,
              onPageChanged: _handlePageChange,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // Vidéo par dessus quand elle est prête
                    if (_chewieControllers[index] != null)
                      Center(
                        child: Chewie(controller: _chewieControllers[index]!),
                      ),
                    // Loader si la vidéo n'est pas prête
                    if (_chewieControllers[index] == null)
                      ChewieVideoPlayer(
                        controller: widget.controllers[index],
                        isFullScreen: true,
                        onTap: () {}, // Pas besoin d'action sur le tap en mode plein écran
                      ),
                  ],
                );
              },
            ),
            const Positioned(
              top: 40,
              left: 20,
              child: Text(
                'FEED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Nettoyer tout lors de la fermeture de la bottom sheet
    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    _chewieControllers.clear();
    _lastAccessTime.clear();
    _thumbnailCache.clear();
    _thumbnailAccessTime.clear();
    _pageController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
