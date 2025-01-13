import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/widget/custom_video_controls.dart';
import '../managers/video_player_manager.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool autoPlay;
  final bool looping;

  const ChewieVideoPlayer({
    required this.videoUrl,
    required this.thumbnailUrl,
    this.autoPlay = false,
    this.looping = true,
    Key? key,
  }) : super(key: key);

  @override
  State<ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final _videoManager = VideoPlayerManager();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = await _videoManager.getController(widget.videoUrl);

    if (mounted) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: widget.autoPlay,
          looping: widget.looping,
          allowFullScreen: true,
          allowMuting: false,
          aspectRatio: 9 / 16,
          showControls: false,
        );
      });
    }
  }

  @override
  void dispose() {
    // Ne pas disposer du contrôleur ici
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        children: [
          // Miniature visible en premier
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Lecteur vidéo
          if (_chewieController != null) Chewie(controller: _chewieController!),
          if (_chewieController == null)
            Center(child: CircularProgressIndicator()),
          // Contrôles personnalisés
          if (_chewieController != null)
            CustomVideoControls(
              controller: _videoPlayerController!,
              chewieController: _chewieController!,
              onPlayPause: () {
                setState(() {
                  if (_chewieController!.isPlaying) {
                    _chewieController!.pause();
                  } else {
                    _chewieController!.play();
                  }
                });
              },
              onExitFullScreen: () {
                // Logique pour quitter le mode plein écran
              },
            ),
        ],
      ),
    );
  }
}
