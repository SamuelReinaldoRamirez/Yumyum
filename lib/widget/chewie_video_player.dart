import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/widget/full_screen_video_feed.dart';
import 'package:yummap/widget/custom_video_controls.dart'; // Importer CustomVideoControls ici

class ChewieVideoPlayer extends StatelessWidget {
  final ChewieController controller;
  final bool isFullScreen;
  final VoidCallback onTap;

  const ChewieVideoPlayer({
    super.key,
    required this.controller,
    required this.isFullScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chewie(controller: controller),
    );
  }
}
