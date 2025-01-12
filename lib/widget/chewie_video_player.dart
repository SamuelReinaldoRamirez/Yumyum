import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/widget/custom_controls.dart';
import 'package:yummap/widget/full_screen_video_feed.dart';
import 'package:yummap/widget/custom_video_controls.dart'; // Importer CustomVideoControls ici

class ChewieVideoPlayer extends StatefulWidget {
  final String videoLink;
  final String thumbnailUrl;  // Ajout du paramètre
  final Function(BuildContext) onFullScreenEntered;

  const ChewieVideoPlayer({
    Key? key,
    required this.videoLink,
    required this.thumbnailUrl,  // Ajout du paramètre
    required this.onFullScreenEntered,
  }) : super(key: key);

  void enterFullScreen(BuildContext context) {
    onFullScreenEntered(context);
  }

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late final VideoPlayerController videoPlayerController;
  late final ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoLink));
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: false,
      aspectRatio: 9 / 16,
      customControls: CustomControls(
        videoPlayerController: videoPlayerController,
        showPlayPause: false,
        showFullScreenButton: true,
      ),
    );
    // Initialiser et mettre en pause immédiatement
    videoPlayerController.initialize().then((_) {
      videoPlayerController.pause();
    });
  }

  void play() {
    chewieController.play();
  }

  void pause() {
    chewieController.pause();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: GestureDetector(
        onTap: () {
          widget.enterFullScreen(context);
        },
        child: Stack(
          children: [
            // Miniature visible en premier
            Positioned.fill(
              child: Image.network(
                widget.thumbnailUrl, // Utiliser le paramètre thumbnailUrl
                fit: BoxFit.cover,
              ),
            ),
            // Lecteur vidéo caché mais préchargé
            Visibility(
              visible: false,
              child: Chewie(controller: chewieController),
            ),
            // Icône de lecture
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black12.withOpacity(0.3),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
