// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
// import 'package:yummap/Restaurant.dart';
// import 'package:yummap/custom_controls.dart';

// class VideoCarousel extends StatefulWidget {
//   final List<String> videoLinks;

//   VideoCarousel({required this.videoLinks});

//   @override
//   _VideoCarouselState createState() => _VideoCarouselState();
// }

// class _VideoCarouselState extends State<VideoCarousel>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   late List<VideoPlayerController> _videoControllers;

//   @override
//   void initState() {
//     super.initState();
//     _videoControllers = List.generate(widget.videoLinks.length, (index) {
//       return VideoPlayerController.network(widget.videoLinks[index]);
//     });
//   }

//   @override
//   void dispose() {
//     _videoControllers.forEach((controller) {
//       controller.dispose();
//     });
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return CarouselSlider.builder(
//       itemCount: widget.videoLinks.length,
//       options: CarouselOptions(
//         height: 200,
//         viewportFraction: 0.6,
//         enableInfiniteScroll: false,
//         enlargeCenterPage: false,
//         initialPage: 0,
//         scrollDirection: Axis.horizontal,
//         onPageChanged: (index, reason) {},
//       ),
//       itemBuilder: (BuildContext context, int index, int realIndex) {
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 8.0),
//           child: InkWell(
//             onTap: () {
//               BottomSheetHelper._showFullScreenVideo(
//                   context, widget.videoLinks[index]);
//             },
//             child: ChewieVideoPlayer(
//               videoController: _videoControllers[index],
//               thumbnailUrl: widget.videoLinks[index]
//                   .replaceFirst(".mp4", ".jpg")
//                   .replaceFirst(".mov", ".jpg")
//                   .replaceFirst("https", "http"),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class BottomSheetHelper {
//   static void showBottomSheet(BuildContext context, Restaurant restaurant,
//       Function navigateToRestaurant) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   restaurant.name,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   restaurant.address,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 VideoCarousel(videoLinks: restaurant.videoLinks),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     navigateToRestaurant(restaurant);
//                   },
//                   child: Text("Y aller"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static void navigateToRestaurant(Restaurant restaurant) async {
//     final url =
//         'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }

//   static void _showFullScreenVideo(
//       BuildContext context, String videoUrl) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: ChewieVideoPlayer(
//               videoController: VideoPlayerController.network(videoUrl),
//               thumbnailUrl: videoUrl
//                   .replaceFirst(".mp4", ".jpg")
//                   .replaceFirst(".mov", ".jpg")
//                   .replaceFirst("https", "http"),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class ChewieVideoPlayer extends StatefulWidget {
//   final VideoPlayerController videoController;
//   final String thumbnailUrl;

//   ChewieVideoPlayer(
//       {required this.videoController, required this.thumbnailUrl});

//   @override
//   _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
// }

// class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
//   late ChewieController _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     _chewieController = ChewieController(
//       videoPlayerController: widget.videoController,
//       autoPlay: false,
//       looping: false,
//       allowFullScreen: true,
//       allowMuting: false,
//       customControls:
//           CustomControls(videoPlayerController: widget.videoController),
//     );
//   }

//   @override
//   void dispose() {
//     _chewieController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 9 / 16,
//       child: Stack(
//         children: [
//           Chewie(controller: _chewieController),
//           Positioned.fill(
//             child: Image.network(
//               widget.thumbnailUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: 10,
//             right: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.black12.withOpacity(0.3),
//               ),
//               padding: EdgeInsets.all(8),
//               child: Icon(
//                 Icons.play_arrow,
//                 color: Colors.white,
//                 size: 32,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/Restaurant.dart';
import 'package:yummap/custom_controls.dart';

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

  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    _videoControllers = List.generate(widget.videoLinks.length, (index) {
      return VideoPlayerController.network(widget.videoLinks[index]);
    });
  }

  @override
  void dispose() {
    _videoControllers.forEach((controller) {
      controller.dispose();
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
            onTap: () {
              BottomSheetHelper._showFullScreenVideo(
                  context, widget.videoLinks[index]);
            },
            child: ChewieVideoPlayer(
              videoController: _videoControllers[index],
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

  // static void _showFullScreenVideo(
  //     BuildContext context, String videoUrl) async {
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: Container(
  //           width: MediaQuery.of(context).size.width,
  //           height: MediaQuery.of(context).size.height,
  //           child: ChewieVideoPlayerFullScreen(
  //             videoUrl: videoUrl,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  static void _showFullScreenVideo(BuildContext context, String videoUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: ChewieVideoPlayerFullScreen(videoUrl: videoUrl),
      ),
    ),
  );
}

}

class ChewieVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final String thumbnailUrl;

  ChewieVideoPlayer(
      {required this.videoController, required this.thumbnailUrl});

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: false,
      customControls:
          CustomControls(videoPlayerController: widget.videoController),
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
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
    );
  }
}

class ChewieVideoPlayerFullScreen extends StatefulWidget {
  final String videoUrl;

  ChewieVideoPlayerFullScreen({required this.videoUrl});

  @override
  _ChewieVideoPlayerFullScreenState createState() =>
      _ChewieVideoPlayerFullScreenState();
}

class _ChewieVideoPlayerFullScreenState
    extends State<ChewieVideoPlayerFullScreen> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
      autoPlay: true, // Démarrage automatique de la vidéo en plein écran
      looping: false,
      allowFullScreen: true,
      allowMuting: false,
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
