import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/bottom_sheet_helper.dart';

class MapPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MapPage({Key? key, required this.restaurantList}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  List<LatLng> restaurantLocations = [];

  @override
  void initState() {
    super.initState();
    MapHelper.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);
    _getCurrentLocation();
    _createMarkers(); // Appel initial pour créer les marqueurs
  }

  void _getCurrentLocation() async {
    MapHelper.getCurrentLocation((Position position) {
      // Utilisez la position ici si nécessaire
    });
  }

  // Modifier _createMarkers pour mettre à jour la liste des marqueurs
  Future<void> _createMarkers() async {
    MarkerManager.markers = MapHelper.createMarkers(
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
        markers: MarkerManager.markers,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: false,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    MarkerManager.mapPageState =
        this as MapPageState?; // Affectation de la référence
    MarkerManager.context = context;
    _setMapStyle(context, mapController);
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(context, restaurant);
  }

  void _setMapStyle(BuildContext context, GoogleMapController mapController) {
    MapHelper.setMapStyle(context, mapController);
  }

  @override
  void dispose() {
    print("++++++++++++++++++++++");
    print("++++++++++++++++++++++");
    print("++++++++++++++++++++++");
    print("++++++++++++++++++++++");
    print("++++++++++++++++++++++");
    print("SOS-MAP");
    super.dispose();
  }
}
