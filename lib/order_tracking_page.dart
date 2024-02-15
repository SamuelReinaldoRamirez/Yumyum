import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:yummap/Restaurant.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/custom_controls.dart';
import 'package:yummap/map_helper.dart';

class OrderTrackingPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const OrderTrackingPage({Key? key, required this.restaurantList})
      : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  late GoogleMapController mapController;
  List<LatLng> restaurantLocations = [];

  @override
  void initState() {
    super.initState();
    MapHelper.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);
    MapHelper.getCurrentLocation(_getCurrentLocation);
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapHelper.buildMap(
        context,
        _createMarkers(context),
        _onMapCreated,
        _setMapStyle,
      ),
    );
  }

  Future<Set<Marker>> _createMarkers(BuildContext context) async {
    return MapHelper.createMarkers(
        context, widget.restaurantList, restaurantLocations, _showMarkerInfo);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(
        context, restaurant, _navigateToRestaurant);
  }

  void _navigateToRestaurant(Restaurant restaurant) async {
    BottomSheetHelper.navigateToRestaurant(restaurant);
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

  Future<void> _setMapStyle() async {
    MapHelper.setMapStyle(context, mapController);
  }

  @override
  void dispose() {
    super.dispose();
  }
}