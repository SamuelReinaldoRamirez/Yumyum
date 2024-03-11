import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';

class MapService {
  /// Obtient la localisation actuelle de l'utilisateur.
  static void getCurrentLocation(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    callback();
  }

  /// Crée des positions de restaurant à partir d'une liste de restaurants.
  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  /// Applique un style personnalisé à la carte.
  static Future<void> setMapStyle(
      BuildContext context, GoogleMapController? mapController) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/custom_map.json');
    mapController?.setMapStyle(style);
  }
}
