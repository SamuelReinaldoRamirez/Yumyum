import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:yummap/constant/theme.dart';

class CustomVideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final ChewieController chewieController;
  final VoidCallback? onExitFullScreen;
  final VoidCallback onPlayPause;

  const CustomVideoControls({
    Key? key,
    required this.controller,
    required this.chewieController,
    required this.onPlayPause,
    this.onExitFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Stack(
        children: [
          // Positioned(
          //   left: 16,
          //   bottom: 16,
          //   child: _NeubrutalButton(
          //     onPressed: onExitFullScreen,
          //     child: const Icon(Icons.close, color: AppColors.white),
          //   ),
          // ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.appSecondary,
                bufferedColor: AppColors.appPrimary.withOpacity(0.5),
                backgroundColor: AppColors.darkGrey.withOpacity(0.3),
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
          Center(
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  opacity: value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: _NeubrutalButton(
                    onPressed: onPlayPause,
                    child: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.white,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
