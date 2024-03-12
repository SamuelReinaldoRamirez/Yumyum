import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';

class MarkerManager {
  static Set<Marker> markers = {};

  static void addMarker(Marker marker) {
    markers.add(marker);
  }

  static void clearMarkers() {
    markers.clear();
  }

  static void removeMarker(Marker marker) {
    markers.remove(marker);
  }
}

class MapHelper {
  static void getCurrentLocation(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    callback();
  }

  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
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
