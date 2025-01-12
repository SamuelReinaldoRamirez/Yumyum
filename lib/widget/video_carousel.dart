// ignore_for_file: library_private_types_in_public_api

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/widget/chewie_video_player.dart';
import 'package:yummap/widget/full_screen_video_feed.dart'; // Import de FullScreenVideoFeed

class VideoCarousel extends StatefulWidget {
  final List<String> videos;

  const VideoCarousel({
    Key? key,
    required this.videos,
  }) : super(key: key);

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  late List<ChewieVideoPlayer> _videoPlayers;
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _videoPlayers = widget.videos.map((video) {
      String thumbnailUrl = video.replaceFirst(".mp4", ".jpg");
      return ChewieVideoPlayer(
        videoLink: video,
        thumbnailUrl: thumbnailUrl,
        onFullScreenEntered: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenVideoFeed(
                videos: widget.videos,
                thumbnailUrls: widget.videos
                    .map((v) => v.replaceFirst(".mp4", ".jpg"))
                    .toList(),
                initialIndex: widget.videos.indexOf(video),
                onVideoChange: (newIndex) {
                  _carouselController.animateToPage(newIndex);
                },
                onExit: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      );
    }).toList();
    _carouselController = CarouselSliderController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: widget.videos.length,
      itemBuilder: (context, index, realIndex) {
        return AspectRatio(
          aspectRatio: 9 / 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 200, // Limiter la hauteur à 200 px
              child: _videoPlayers[index],
            ),
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 9 / 16,
        viewportFraction: 0.3,
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
