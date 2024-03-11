import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/restaurant.dart';

class MarkerManager {
  static Set<Marker> markers = {};

  static void addMarker(Marker marker) {
    markers.add(marker);
  }

  static void clearMarkers() {
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    print("-------------------");
    //print(markers.first);
    markers.clear();
    //print(markers.first);
  }

  static void pop() {}
}

class MapHelper {
  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  static Future<void> getCurrentLocation(Function callback) async {
    // Code pour obtenir la localisation actuelle
  }

  static Widget buildMap(
    BuildContext context,
    Future<Set<Marker>> markersFuture,
    Function(GoogleMapController) onMapCreated,
    Function setMapStyle,
  ) {
    return FutureBuilder<Set<Marker>>(
      future: markersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.339),
              zoom: 12,
            ),
            markers: MarkerManager.markers,
            myLocationEnabled: true,
            onMapCreated: onMapCreated,
            zoomControlsEnabled: false,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
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
      //markers.add(marker);
      MarkerManager.addMarker(marker);
    }

    return markers;
  }

  static Future<void> setMapStyle(
      BuildContext context, GoogleMapController mapController) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    mapController.setMapStyle(style);
  }
}
