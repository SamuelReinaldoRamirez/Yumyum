// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:yummap/chewie_video_player.dart';

class VideoCarousel extends StatefulWidget {
  final List<String> videoLinks;

  const VideoCarousel({super.key, required this.videoLinks});

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<ChewieVideoPlayer> _videoPlayers;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  void _initializeVideoPlayers() {
    _videoPlayers = widget.videoLinks.map((videoLink) {
      return ChewieVideoPlayer(
        videoLink: videoLink,
        thumbnailUrl: videoLink
            .replaceFirst(".mp4", ".jpg")
            .replaceFirst(".mov", ".jpg")
            .replaceFirst("https", "http"),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CarouselSlider.builder(
      itemCount: widget.videoLinks.length,
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.6,
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
        initialPage: 0,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {},
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _videoPlayers[index],
        );
      },
    );
  }
}
