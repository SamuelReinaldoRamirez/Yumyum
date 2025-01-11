import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:yummap/constant/keys_data.dart';

class MapPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MapPage({super.key, required this.restaurantList});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> with WidgetsBindingObserver {
  late MapController mapController;
  List<lat2.LatLng> restaurantLocations = [];
  Timer? _locationUpdateTimer;
  Marker? userMarker;
  List<Marker>? _markers;
  Timer? _updateTimer;
  final ValueNotifier<Marker?> userMarkerNotifier =
      ValueNotifier<Marker?>(null);
  final ValueNotifier<Marker?> userMarkerNotifier2 =
      ValueNotifier<Marker?>(null);
  final ValueNotifier<Marker?> userMarkerNotifier3 =
      ValueNotifier<Marker?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MapHelper.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);

    mapController = MapController();
    MarkerManager.mapPageState = this;
    MarkerManager.context = context;
    _createListMarkers(); // Appel initial pour créer les marqueurs
    _getCurrentLocation();
    //_startLocationUpdates(); // Démarrer les mises à jour de la position de l'utilisateur
    _updatePins();
    _updateTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      _updatePins();
    });
  }

  void _getCurrentLocation() async {
    MapHelper.getCurrentLocation((Position position) {
      // Initialiser la position de l'utilisateur si nécessaire
      if (userMarkerNotifier.value == null) {
        userMarkerNotifier.value = Marker(
          width: 20.0,
          height: 20.0,
          point: lat2.LatLng(position.latitude, position.longitude),
          builder: (ctx) => const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
        MarkerManager.addMarker(userMarkerNotifier
            .value!); // Ajouter le marqueur à la liste des marqueurs
      }
    });
  }

  void _centercamera() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    mapController.move(lat2.LatLng(position.latitude, position.longitude), 12);
  }

  Future<void> _createListMarkers() async {
    List<Marker> newMarkers =
        await MapHelper.createMarkersFromRestaurants(widget.restaurantList);
    MarkerManager.swapMarkersList(newMarkers);
    MarkerManager.allmarkers = List<Marker>.from(newMarkers);
  }

  void _updatePins() {
    _createListMarkers(); // Supprimez setState car nous utilisons maintenant ValueNotifier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: lat2.LatLng(48.8566, 2.339),
              zoom: 12,
              maxZoom: 18.4,
              minZoom: 1,
              onTap: (tapPosition, point) {
                // Fermer le clavier lors du tap sur la carte
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=$mapBoxToken",
                subdomains: const ['a', 'b', 'c'],
              ),
              ValueListenableBuilder<Marker?>(
                valueListenable: userMarkerNotifier,
                builder: (context, userMarker, child) {
                  final List<Marker> allMarkers = [
                    ...MarkerManager.markersList
                  ];
                  if (userMarker != null) {
                    allMarkers.add(userMarker);
                  }
                  return MarkerLayer(markers: allMarkers);
                },
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SizedBox(
              width: 60.0,
              height: 60.0,
              child: SizedBox(
                width: 60.0,
                height: 60.0,
                child: FloatingActionButton(
                  onPressed: _centercamera,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _disposeMapResources() {
    mapController.dispose();
    _markers?.clear();
    _locationUpdateTimer?.cancel();
    userMarkerNotifier.dispose();
    userMarkerNotifier2.dispose();
    userMarkerNotifier3.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeMapResources();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _disposeMapResources();
    } else if (state == AppLifecycleState.resumed) {
      _reinitializeMap();
    }
  }

  Future<void> _reinitializeMap() async {
    // Réinitialiser la carte et les marqueurs
  }
}
