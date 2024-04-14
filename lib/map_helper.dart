import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_page.dart';
import 'package:yummap/tracking_transparency_helper.dart';
import 'package:latlong2/latlong.dart' as lat2;

class MarkerManager {
  //static Set<Marker> markers = {};
  static List<Marker> allmarkers = [];
  static MapPageState? mapPageState;
  static List<Marker> markersList = [];
  static late BuildContext context;

  static void addMarker(Marker marker) {
    markersList.add(marker);
    updateMap();
  }

  static void clearMarkers() {
    markersList.clear();
    updateMap();
  }

  static void removeMarker(Marker marker) {
    markersList.remove(marker);
    updateMap();
  }

  static void pop() {
    markersList.remove(markersList.first);
    updateMap();
  }

  static void updateMap() {
    // ignore: invalid_use_of_protected_member
    mapPageState?.setState(() {});
  }

  static void createFull(
      BuildContext context, List<Restaurant> newRestaurants) {
    MapHelper.createFull(mapPageState!.context, newRestaurants);
    updateMap();
  }

  static void resetMarkers() {
    markersList = List<Marker>.from(allmarkers);
    updateMap();
  }
}

class MapHelper {
  static void getCurrentLocation(Function(Position) callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    callback(position);
    Marker marker = Marker(
      width: 20.0,
      height: 20.0,
      point: lat2.LatLng(
          position.latitude,
          position
              .longitude), // Utilisation de LatLng pour définir les coordonnées
      builder: (ctx) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
    MarkerManager.addMarker(marker);
    MarkerManager.updateMap();
  }

  static Future<void> requestAppTrackingAuthorization(context) async {
    TrackingStatusDialog.requestAppTrackingAuthorization(context);
  }

  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<lat2.LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(lat2.LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  static void createFull(
      BuildContext context, List<Restaurant> newRestaurants) {
    List<lat2.LatLng> newLocations = [];
    createRestaurantLocations(newRestaurants, newLocations);
    List<Marker> newMarkers = MapHelper.createListMarkers(
        context, newRestaurants, newLocations, _showMarkerInfo);
    MarkerManager.markersList = newMarkers;
  }

  static void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(context, restaurant);
  }

  static Future<void> setMapStyle(
      BuildContext context, MapController mapController) async {
    // String style = await DefaultAssetBundle.of(context)
    //     .loadString('assets/custom_map.json');
    //mapController.style(style);
  }

  static List<Marker> createMarkers(
      BuildContext context,
      List<Restaurant> restaurantList,
      List<lat2.LatLng> restaurantLocations,
      Function(BuildContext context, Restaurant r) showMarkerInfo) {
    List<Marker> markers = [];

    for (int i = 0; i < restaurantLocations.length; i++) {
      Marker marker = Marker(
          point: restaurantLocations[i],
          builder: showMarkerInfo(context, restaurantList[i]));
      markers.add(marker);
    }

    MarkerManager.markersList = markers;
    return markers;
  }

  static List<Marker> createListMarkers(
    BuildContext context,
    List<Restaurant> restaurantList,
    List<lat2.LatLng> restaurantLocations,
    Function(BuildContext context, Restaurant r) showMarkerInfo,
  ) {
    List<Marker> markers = [];

    for (int i = 0; i < restaurantLocations.length; i++) {
      Marker marker = Marker(
        width: 30,
        height: 30,
        point: restaurantLocations[i],
        builder: (ctx) => GestureDetector(
          onTap: () {
            print(
                "Tap"); // Imprime "Tap" lorsque l'utilisateur tape sur le marqueur
            showMarkerInfo(context, restaurantList[i]);
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF95A472),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // Centrer l'icône à l'intérieur du cercle
                  child: Icon(
                    Icons.local_dining_outlined, // Utiliser l'icône de broche
                    size: 24, // Ajuster la taille de l'icône selon vos besoins
                    color: Color(0xFFDDFCAD), // Couleur de l'icône
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      markers.add(marker);
    }

    MarkerManager.markersList = markers;
    return markers;
  }
}
