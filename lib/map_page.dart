import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/call_endpoint_service.dart';
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
  Set<Marker> markers = {}; // Champ pour stocker les marqueurs
  List<LatLng> restaurantLocations = [];

  @override
  void initState() {
    super.initState();
    MapService.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);
    _getCurrentLocation();
    _createMarkers(); // Appel initial pour créer les marqueurs
  }

  void _getCurrentLocation() async {
    MapService.getCurrentLocation((Position position) {
      // Utilisez la position ici si nécessaire
    });
  }

  // Modifier _createMarkers pour mettre à jour la liste des marqueurs
  Future<void> _createMarkers() async {
    markers = await MapHelper.createMarkers(
        context, widget.restaurantList, restaurantLocations, _showMarkerInfo);
    setState(
        () {}); // Mettre à jour l'état pour reconstruire la carte avec les nouveaux marqueurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(48.8566, 2.339),
          zoom: 12,
        ),
        markers: markers,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clearMarkers,
        child: Icon(Icons.clear),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle(context, mapController);
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(
        context, restaurant, _navigateToRestaurant);
  }

  void _navigateToRestaurant(Restaurant restaurant) async {
    // Votre code pour naviguer vers la page du restaurant
  }

  void _setMapStyle(BuildContext context, GoogleMapController mapController) {
    MapService.setMapStyle(context, mapController);
  }

  Future<void> clearMarkers() async {
    //************* IL FAUT REMPLACER [1] Par l'id du tag de l'utilisateur */
    List<Restaurant> newRestaurants =
        await CallEndpointService.getRestaurantsByTags([1]);
    List<LatLng> newLocations = [];
    MapService.createRestaurantLocations(newRestaurants, newLocations);
    Set<Marker> newMarkers = MapHelper.createMarkers(
        context, newRestaurants, newLocations, _showMarkerInfo);

    setState(() {
      markers = newMarkers; // Remplacez les anciens marqueurs par les nouveaux
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
