import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:latlong2/latlong.dart' as lat2;

class MapPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MapPage({Key? key, required this.restaurantList}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late MapController mapController;
  List<lat2.LatLng> restaurantLocations = [];

  @override
  void initState() {
    super.initState();
    MapHelper.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);

    mapController = MapController();
    //_requestAppTrackingAuthorization(context);
    MarkerManager.mapPageState = this;
    MarkerManager.context = context;
    _createListMarkers(); // Appel initial pour créer les marqueurs
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    MapHelper.getCurrentLocation((Position position) {
      // Utilisez la position ici si nécessaire
    });
  }

  void _centercamera() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    mapController.move(lat2.LatLng(position.latitude, position.longitude), 12);
  }

  Future<void> _createListMarkers() async {
    MarkerManager.markersList = MapHelper.createListMarkers(
        context, widget.restaurantList, restaurantLocations, _showMarkerInfo);
    MarkerManager.allmarkers = List<Marker>.from(MarkerManager.markersList);
    setState(
        () {}); // Mettre à jour l'état pour reconstruire la carte avec les nouveaux marqueurs
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
                    "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieXVtbWFwcyIsImEiOiJjbHJ0aDEzeGQwMXVkMmxudWg5d2EybTlqIn0.hqUva2cQmp3rXHMbON8_Kw",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: MarkerManager.markersList),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _centercamera,
              child: Icon(Icons.my_location),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    // Envoyer l'événement "OpenPin" à Mixpanel
    MixpanelService.instance.track('OpenPin', properties: {
      'resto_id': restaurant.id,
      'resto_name': restaurant.name,
    });

    mapController.move(lat2.LatLng(restaurant.latitude, restaurant.longitude),
        mapController.zoom);
    BottomSheetHelper.showBottomSheet(context, restaurant);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
