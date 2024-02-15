import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/Restaurant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism/glassmorphism.dart';

class OrderTrackingPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const OrderTrackingPage({Key? key, required this.restaurantList})
      : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  List<LatLng> restaurantLocations = [];
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _createRestaurantLocations();
  }

  void _createRestaurantLocations() {
    for (var restaurant in widget.restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(48.8566, 2.339),
          zoom: 12,
        ),
        markers: _createMarkers(),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _setMapStyle();
        },
      ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    for (int i = 0; i < restaurantLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(widget.restaurantList[i].name),
          position: restaurantLocations[i],
          onTap: () {
            _showMarkerInfo(context, widget.restaurantList[i]);
          },
        ),
      );
    }

    return markers;
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) async {
    try {
      _showBottomSheet(context, restaurant);
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildChewieVideoPlayer(String videoUrl,
      {required String thumbnailUrl}) {
    final videoPlayerController = VideoPlayerController.network(videoUrl);

    return FutureBuilder(
      future: videoPlayerController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: false,
            looping: false,
            allowFullScreen: true,
            allowMuting: false,
            customControls:
                CustomControls(videoPlayerController: videoPlayerController),
            aspectRatio: 9 / 16,
          );

          Completer<void> fullScreenCompleter = Completer<void>();

          return GestureDetector(
            onTap: () async {
              chewieController.addListener(() {
                if (chewieController.isFullScreen &&
                    !fullScreenCompleter.isCompleted) {
                  fullScreenCompleter.complete();
                }
              });

              chewieController.enterFullScreen();

              await fullScreenCompleter.future;

              chewieController.play();

              print("Fullscreen");
              print(videoUrl);
            },
            child: Stack(
              children: [
                TickerMode(
                  enabled: true,
                  child: Chewie(controller: chewieController),
                ),
                Positioned.fill(
                  child: Image.network(
                    thumbnailUrl,
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
        } else if (snapshot.hasError) {
          print("Error initializing video: ${snapshot.error}");
          return Center(child: Text("Error loading video"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showBottomSheet(BuildContext context, Restaurant restaurant) {
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
                CarouselSlider.builder(
                  itemCount: restaurant.videoLinks.length,
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 0.6,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: false,
                    initialPage: 0,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {},
                  ),
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: 300,
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
                        child: Stack(
                          children: [
                            _buildChewieVideoPlayer(
                              restaurant.videoLinks[index],
                              thumbnailUrl: restaurant.videoLinks[index]
                                  .replaceFirst(".mp4", ".jpg")
                                  .replaceFirst(".mov", ".jpg")
                                  .replaceFirst("https", "http"),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
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
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _navigateToRestaurant(restaurant);
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

  void _navigateToRestaurant(Restaurant restaurant) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> _setMapStyle() async {
    // Charger le contenu du fichier JSON
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/custom_map.json');

    // Appliquer le style à la carte
    mapController.setMapStyle(style);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomControls extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  CustomControls({required this.videoPlayerController});

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
