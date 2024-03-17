import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:video_player/video_player.dart';

class CustomControls extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool showPlayPause;
  final bool showFullScreenButton;

  CustomControls({
    required this.videoPlayerController,
    required this.showPlayPause,
    required this.showFullScreenButton,
  });

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.videoPlayerController.pause();
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                GlassmorphicContainer(
                  width: 100,
                  height: 40,
                  borderRadius: 20,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1)
                    ],
                  ),
                  border: 2,
                  blur: 10,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.2)
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (widget.videoPlayerController.value.isPlaying) {
                        widget.videoPlayerController.pause();
                      } else {
                        widget.videoPlayerController.play();
                      }
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    icon: Icon(
                      isPlaying ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
