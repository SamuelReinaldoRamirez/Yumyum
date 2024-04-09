import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_page.dart';

class MarkerManager {
  static Set<Marker> markers = {};
  static Set<Marker> allmarkers = {};
  static MapPageState? mapPageState;
  static late BuildContext context;

  static void addMarker(Marker marker) {
    markers.add(marker);
    updateMap();
  }

  static void clearMarkers() {
    markers.clear();
    updateMap();
  }

  static void removeMarker(Marker marker) {
    markers.remove(marker);
    updateMap();
  }

  static void pop() {
    markers.remove(markers.first);
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
    markers = Set<Marker>.from(allmarkers);
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
    MarkerManager.updateMap();
  }

  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  static void createFull(
      BuildContext context, List<Restaurant> newRestaurants) {
    List<LatLng> newLocations = [];
    createRestaurantLocations(newRestaurants, newLocations);
    Set<Marker> newMarkers = MapHelper.createMarkers(
        context, newRestaurants, newLocations, _showMarkerInfo);
    MarkerManager.markers = newMarkers;
  }

  static void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(context, restaurant);
  }

  static Future<void> setMapStyle(
      BuildContext context, GoogleMapController mapController) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/custom_map.json');
    mapController.setMapStyle(style);
  }

  static Set<Marker> createMarkers(
      BuildContext context,
      List<Restaurant> restaurantList,
      List<LatLng> restaurantLocations,
      Function(BuildContext context, Restaurant r) showMarkerInfo) {
    Set<Marker> markers = {};

    for (int i = 0; i < restaurantLocations.length; i++) {
      Marker marker = Marker(
        markerId: MarkerId(restaurantList[i].name),
        position: restaurantLocations[i],
        onTap: () {
          showMarkerInfo(context, restaurantList[i]);
        },
      );
      markers.add(marker);
    }

    MarkerManager.markers = markers;
    return markers;
  }
}
