import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yummap/Restaurant.dart';
import 'package:yummap/bottom_sheet_helper.dart';
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
        _setMapStyle, // Ajout de l'argument manquant ici
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

  Future<void> _setMapStyle() async {
    MapHelper.setMapStyle(context, mapController);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
