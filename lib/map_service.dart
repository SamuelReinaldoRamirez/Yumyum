import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';

class MapService {
  /// Obtient la localisation actuelle de l'utilisateur.
  ///
  /// [callback] est une fonction qui sera appelée une fois que la localisation sera récupérée.
  static void getCurrentLocation(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    callback();
  }

  /// Crée des positions de restaurant à partir d'une liste de restaurants.
  ///
  /// [restaurantList] Liste des restaurants.
  /// [restaurantLocations] Liste des positions des restaurants.
  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  /// Efface tous les marqueurs de la carte.
  ///
  /// [markers] Ensemble des marqueurs à effacer.
  static void clearMarkers(Set<Marker> markers) {
    markers.clear();
  }

  /// Applique un style personnalisé à la carte.
  ///
  /// [context] Contexte de l'application.
  /// [mapController] Contrôleur de la carte Google.
  static Future<void> setMapStyle(
      BuildContext context, GoogleMapController? mapController) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/custom_map.json');
    mapController?.setMapStyle(style);
  }

  static Set<Marker> createMarkers(
      BuildContext context,
      List<Restaurant> restaurantList,
      List<LatLng> restaurantLocations,
      Function(BuildContext context, Restaurant r) showMarkerInfo) {
    Set<Marker> markers = {};

    for (int i = 0; i < restaurantLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(restaurantList[i].name),
          position: restaurantLocations[i],
          onTap: () {
            showMarkerInfo(context, restaurantList[i]);
          },
        ),
      );
    }

    return markers;
  }
}
