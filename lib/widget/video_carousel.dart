// ignore_for_file: library_private_types_in_public_api

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/widget/chewie_video_player.dart';
import 'package:yummap/widget/full_screen_video_feed.dart'; // Import de FullScreenVideoFeed

class VideoCarousel extends StatefulWidget {
  final List<String> videoLinks;

  const VideoCarousel({super.key, required this.videoLinks});

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel>
    with AutomaticKeepAliveClientMixin {
  late List<ChewieController> _chewieControllers;
  List<String> _thumbnailUrls = [];
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // Charger d'abord les miniatures car c'est plus rapide
    _loadThumbnails();
    setState(() => _isLoading = true);

    // Charger les contrôleurs en arrière-plan
    _initializeControllers().then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _loadThumbnails() {
    _thumbnailUrls = widget.videoLinks.map((videoLink) {
      return getThumbnailUrl(videoLink);
    }).toList();
    setState(() {});
  }

  Future<void> _initializeControllers() async {
    if (_isInitialized) return;

    _chewieControllers = widget.videoLinks.map((videoLink) {
      final controller = VideoPlayerController.network(videoLink);
      return ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: true,
        aspectRatio: 9 / 16,
      );
    }).toList();

    _isInitialized = true;
  }

  void _handleThumbnailTap(int index) {
    if (!_isInitialized) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoFeed(
          controllers: _chewieControllers,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _chewieControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CarouselSlider.builder(
      itemCount: widget.videoLinks.length,
      itemBuilder: (context, index, realIndex) {
        return GestureDetector(
          onTap: () => _handleThumbnailTap(index),
          child: AspectRatio(
            aspectRatio: 9/16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _thumbnailUrls.isNotEmpty
                      ? NetworkImage(_thumbnailUrls[index])
                      : const AssetImage('assets/placeholder.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.4,
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
        initialPage: 0,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  String getThumbnailUrl(String videoLink) {
    return videoLink
        .replaceFirst('.mp4', '.jpg')
        .replaceFirst('.mov', '.jpg')
        .replaceFirst('https', 'http');
  }
}
