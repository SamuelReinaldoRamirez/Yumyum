import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/map_service.dart'; // Import de MapService

class MapPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MapPage({Key? key, required this.restaurantList}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  //Set<Marker> markers = {};
  List<LatLng> restaurantLocations = [];

  @override
  void initState() {
    super.initState();
    MapService.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    MapService.getCurrentLocation((Position position) {
      // Utilisez la position ici si nécessaire
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapHelper.buildMap(
        context,
        _createMarkers(), // Correction ici
        _onMapCreated,
        _setMapStyle,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clearMarkers,
        child: Icon(Icons.clear),
      ),
    );
  }

  Future<Set<Marker>> _createMarkers() async {
    return MapHelper.createMarkers(
        context, widget.restaurantList, restaurantLocations, _showMarkerInfo);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle(context, mapController); // Correction ici
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(
        context, restaurant, _navigateToRestaurant);
  }

  void _navigateToRestaurant(Restaurant restaurant) async {
    // Votre code pour naviguer vers la page du restaurant
  }

  void _setMapStyle(BuildContext context, GoogleMapController mapController) {
    MapService.setMapStyle(context, mapController); // Correction ici
  }

  void clearMarkers() {
    setState(() {
      //apService.clearMarkers(markers); // Utilisation de MapService
      MarkerManager.clearMarkers(); // Clear markers managed by MarkerManager
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
