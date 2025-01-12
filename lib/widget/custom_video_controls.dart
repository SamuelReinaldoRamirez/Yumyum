import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/constant/theme.dart';

class CustomVideoControls extends StatelessWidget {
  final VideoPlayerController videoPlayerController;
  final bool showPlayPause;
  final bool showFullScreenButton;
  final VoidCallback? onToggleFullScreen;

  const CustomVideoControls({
    Key? key,
    required this.videoPlayerController,
    this.showPlayPause = true,
    this.showFullScreenButton = true,
    this.onToggleFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient overlay pour meilleure lisibilité des contrôles
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        // Contrôles
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Column(
            children: [
              // Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ValueListenableBuilder(
                  valueListenable: videoPlayerController,
                  builder: (context, VideoPlayerValue value, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.position.inMilliseconds /
                            value.duration.inMilliseconds,
                        child: Container(
                          color: AppColors.appPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Boutons de contrôle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (showPlayPause)
                    _buildControlButton(
                      icon: videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      onPressed: () {
                        videoPlayerController.value.isPlaying
                            ? videoPlayerController.pause()
                            : videoPlayerController.play();
                      },
                    ),
                  if (showFullScreenButton)
                    _buildControlButton(
                      icon: Icons.fullscreen,
                      onPressed: onToggleFullScreen,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.appSecondary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.appSecondary,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: AppColors.appSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
