import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/Restaurant.dart';
import 'package:yummap/custom_controls.dart';

Completer<void> fullScreenCompleter = Completer<void>();

class VideoCarousel extends StatefulWidget {
  final List<String> videoLinks;

  VideoCarousel({required this.videoLinks});

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<ChewieController> _chewieControllers;

  @override
  void initState() {
    super.initState();
    _initializeChewieControllers();
  }

  void _initializeChewieControllers() {
    _chewieControllers = List.generate(widget.videoLinks.length, (index) {
      final videoPlayerController = VideoPlayerController.network(
        widget.videoLinks[index],
      );
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: false,
        customControls: CustomControls(
          videoPlayerController: videoPlayerController,
        ),
      );
      // Initialiser le lecteur vidéo à partir de l'URL correcte
      videoPlayerController.initialize().then((_) {
        setState(
            () {}); // Rafraîchir l'interface utilisateur après l'initialisation
      });
      return chewieController;
    });
  }

  @override
  void dispose() {
    _chewieControllers.forEach((controller) {
      controller.dispose();
      controller.videoPlayerController.dispose();
    });
    super.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () async {
              await BottomSheetHelper.showFullScreenVideo(
                  context, _chewieControllers[index], widget.videoLinks[index]);
            },
            child: ChewieVideoPlayer(
              chewieController: _chewieControllers[index],
              thumbnailUrl: widget.videoLinks[index]
                  .replaceFirst(".mp4", ".jpg")
                  .replaceFirst(".mov", ".jpg")
                  .replaceFirst("https", "http"),
            ),
          ),
        );
      },
    );
  }
}

class BottomSheetHelper {
  static void showBottomSheet(BuildContext context, Restaurant restaurant,
      Function navigateToRestaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  restaurant.address,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                VideoCarousel(videoLinks: restaurant.videoLinks),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    navigateToRestaurant(restaurant);
                  },
                  child: Text("Y aller"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void navigateToRestaurant(Restaurant restaurant) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  static Future<void> showFullScreenVideo(
    BuildContext context,
    ChewieController chewieController,
    String videoUrl,
  ) async {
    chewieController.addListener(() {
      if (chewieController.isFullScreen && !fullScreenCompleter.isCompleted) {
        fullScreenCompleter.complete();
      }
    });

    chewieController.enterFullScreen();

    await fullScreenCompleter.future; // Attendre la complétion

    chewieController.play();

    print("Fullscreen");
    print(videoUrl);
  }
}

class ChewieVideoPlayer extends StatefulWidget {
  final ChewieController chewieController;
  final String thumbnailUrl;

  ChewieVideoPlayer(
      {required this.chewieController, required this.thumbnailUrl});

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        children: [
          Chewie(controller: widget.chewieController),
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
    );
  }
}
