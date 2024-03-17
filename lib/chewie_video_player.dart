import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'custom_controls.dart'; // Importer CustomControls ici

class ChewieVideoPlayer extends StatefulWidget {
  final String videoLink;
  final String thumbnailUrl;

  ChewieVideoPlayer({required this.videoLink, required this.thumbnailUrl});

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoLink);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: false,
      customControls: CustomControls(
        // Utiliser CustomControls ici
        videoPlayerController:
            _videoPlayerController, // Ajouter le contrôleur vidéo
        showPlayPause:
            false, // Par exemple, définir les options de contrôle personnalisées
        showFullScreenButton: true,
      ),
    );
    _videoPlayerController.initialize().then((_) {
      setState(
          () {}); // Rafraîchir l'interface utilisateur après l'initialisation
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: GestureDetector(
        onTap: () {
          _enterFullScreen(context);
        },
        child: Stack(
          children: [
            Chewie(controller: _chewieController),
            Positioned.fill(
              child: Image.network(
                widget.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black12.withOpacity(0.3),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
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

  void _enterFullScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Chewie(
              controller: _chewieController,
            ),
          ),
        ),
      ),
    );
  }
}
