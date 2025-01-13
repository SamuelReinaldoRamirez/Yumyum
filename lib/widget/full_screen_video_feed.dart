import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/managers/video_player_manager.dart';
import 'package:yummap/widget/chewie_video_player.dart';

class FullScreenVideoFeed extends StatefulWidget {
  final List<String> videos;
  final int initialIndex;
  final VoidCallback? onExit;
  final Function onNavigateToDetails; // Nouveau paramètre

  const FullScreenVideoFeed({
    required this.videos,
    required this.initialIndex,
    this.onExit,
    required this.onNavigateToDetails, // Nouveau paramètre
    Key? key,
  }) : super(key: key);

  @override
  _FullScreenVideoFeedState createState() => _FullScreenVideoFeedState();
}

class _FullScreenVideoFeedState extends State<FullScreenVideoFeed> {
  late PageController _pageController;
  late int _currentIndex;
  final _videoManager = VideoPlayerManager();
  String? _currentVideoUrl;
// État pour suivre si la vidéo a été lue
// État pour suivre si la vidéo a été lue au moins une fois

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentVideoUrl = widget.videos[widget.initialIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _videoManager.play(_currentVideoUrl!);
        setState(() {
// Marquer comme lu
// Marquer comme lu au moins une fois
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir
      body: GestureDetector(
        onHorizontalDragEnd: _handleDragEnd, // Assurez-vous que cette ligne est présente
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.videos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final videoUrl = widget.videos[index];
                return Container(
                  color: Colors.black, // Fond noir
                  child: Center(
                    // Centrer le ChewieVideoPlayer
                    child: ChewieVideoPlayer(
                      videoUrl: videoUrl,
                      thumbnailUrl: videoUrl.replaceFirst('.mp4', '.jpg'),
                      autoPlay: index == widget.initialIndex,
                      looping: true,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: _NeubrutalButton(
                onPressed: () {
                  _videoManager.pause(_currentVideoUrl!); // Pause la vidéo actuelle
                  VideoPlayerManager().pauseAll(); // Mettre en pause toutes les vidéos
                  Navigator.of(context).pop(); // Quitter le mode plein écran
                },
                child: const Icon(Icons.close, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Swipe vers la droite -> fermer
      widget.onExit?.call(); // Utiliser onExit pour fermer
    } else if (details.primaryVelocity! < 0) {
      // Swipe vers la gauche -> détails
      widget.onNavigateToDetails.call(); // Ouvre les détails du restaurant
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      if (_currentVideoUrl != null) {
        _videoManager.pause(_currentVideoUrl!); // Pause la vidéo actuelle
      }
      _currentVideoUrl =
          widget.videos[index]; // Met à jour l'URL de la vidéo actuelle
      _videoManager.play(_currentVideoUrl!); // Joue la nouvelle vidéo
      setState(() => _currentIndex = index);
    }
  }

  @override
  void dispose() {
    _videoManager.pause(_currentVideoUrl!); // Pause la vidéo actuelle
    VideoPlayerManager().pauseAll(); // Mettre en pause toutes les vidéos
    if (widget.onExit != null) {
      widget.onExit!(); // Appeler la fonction onExit pour gérer l'état
    }
    super.dispose();
  }
}

class _NeubrutalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _NeubrutalButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.appSecondary.withOpacity(0.7),
            border: Border.all(
              color: AppColors.borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}
