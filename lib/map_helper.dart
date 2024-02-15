// // import 'dart:js';

// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:yummap/Restaurant.dart';

// // class MapHelper {
// //   static void getCurrentLocation(Function callback) async {
// //     LocationPermission permission = await Geolocator.requestPermission();
// //     if (permission == LocationPermission.denied) {
// //       return;
// //     }
// //     callback();
// //   }

// //   static void createRestaurantLocations(List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
// //     for (var restaurant in restaurantList) {
// //       restaurantLocations.add(LatLng(restaurant.latitude, restaurant.longitude));
// //     }
// //   }

// //   static Widget buildMap(BuildContext context, Function createMarkers, GoogleMapController? mapController, Function setMapStyle) {
// //     return GoogleMap(
// //       initialCameraPosition: CameraPosition(
// //         target: LatLng(48.8566, 2.339),
// //         zoom: 12,
// //       ),
// //       markers: createMarkers(),
// //       myLocationEnabled: true,
// //       onMapCreated: (GoogleMapController controller) {
// //         mapController = controller;
// //         setMapStyle();
// //       },
// //       zoomControlsEnabled: false,
// //     );
// //   }

// //   // static Set<Marker> createMarkers(List<Restaurant> restaurantList, List<LatLng> restaurantLocations, Function(BuildContext context, Restaurant r) showMarkerInfo) {
// //   //   Set<Marker> markers = {};

// //   //   for (int i = 0; i < restaurantLocations.length; i++) {
// //   //     markers.add(
// //   //       Marker(
// //   //         markerId: MarkerId(restaurantList[i].name),
// //   //         position: restaurantLocations[i],
// //   //         onTap: () {
// //   //           showMarkerInfo(context as BuildContext, restaurantList[i]);
// //   //         },
// //   //       ),
// //   //     );
// //   //   }

// //   //   return markers;
// //   // }

// //   static Set<Marker> createMarkers(List<Restaurant> restaurantList, List<LatLng> restaurantLocations, Function(BuildContext context, Restaurant r) showMarkerInfo) {
// //   Set<Marker> markers = {};

// //   for (int i = 0; i < restaurantLocations.length; i++) {
// //     markers.add(
// //       Marker(
// //         markerId: MarkerId(restaurantList[i].name),
// //         position: restaurantLocations[i],
// //         onTap: () {
// //           print("***********");
// //           //print(context);
// //           //showMarkerInfo(context, restaurantList[i]);
// //         },
// //       ),
// //     );
// //   }

// //   return markers;
// // }


// //   static Future<void> setMapStyle(BuildContext context, GoogleMapController? mapController) async {
// //     String style = await DefaultAssetBundle.of(context)
// //         .loadString('assets/custom_map.json');
// //     mapController?.setMapStyle(style);
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:yummap/Restaurant.dart';

// class MapHelper {
//   static void getCurrentLocation(Function callback) async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return;
//     }
//     callback();
//   }

//   static void createRestaurantLocations(List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
//     for (var restaurant in restaurantList) {
//       restaurantLocations.add(LatLng(restaurant.latitude, restaurant.longitude));
//     }
//   }

//   static Widget buildMap(BuildContext context, Function createMarkers, GoogleMapController? mapController, Function setMapStyle) {
//     return GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: LatLng(48.8566, 2.339),
//         zoom: 12,
//       ),
//       markers: createMarkers(context),
//       myLocationEnabled: true,
//       onMapCreated: (GoogleMapController controller) {
//         mapController = controller;
//         setMapStyle();
//       },
//       zoomControlsEnabled: false,
//     );
//   }

//   static Set<Marker> createMarkers(BuildContext context, List<Restaurant> restaurantList, List<LatLng> restaurantLocations, Function(BuildContext context, Restaurant r) showMarkerInfo) {
//     Set<Marker> markers = {};

//     for (int i = 0; i < restaurantLocations.length; i++) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(restaurantList[i].name),
//           position: restaurantLocations[i],
//           onTap: () {
//             showMarkerInfo(context, restaurantList[i]);
//           },
//         ),
//       );
//     }

//     return markers;
//   }

//   static Future<void> setMapStyle(BuildContext context, GoogleMapController? mapController) async {
//     String style = await DefaultAssetBundle.of(context)
//         .loadString('assets/custom_map.json');
//     mapController?.setMapStyle(style);
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/Restaurant.dart';

class MapHelper {
  static void getCurrentLocation(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    callback();
  }

  static void createRestaurantLocations(List<Restaurant> restaurantList, List<LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations.add(LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  // static Widget buildMap(BuildContext context, Set<Marker> markers, GoogleMapController? mapController, Function setMapStyle) {
  //   return GoogleMap(
  //     initialCameraPosition: CameraPosition(
  //       target: LatLng(48.8566, 2.339),
  //       zoom: 12,
  //     ),
  //     markers: markers,
  //     myLocationEnabled: true,
  //     onMapCreated: (GoogleMapController controller) {
  //       mapController = controller;
  //       setMapStyle();
  //     },
  //     zoomControlsEnabled: false,
  //   );
  // }

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
          initialCameraPosition: CameraPosition(
            target: LatLng(48.8566, 2.339),
            zoom: 12,
          ),
          markers: snapshot.data ?? Set<Marker>(),
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


  static Set<Marker> createMarkers(BuildContext context, List<Restaurant> restaurantList, List<LatLng> restaurantLocations, Function(BuildContext context, Restaurant r) showMarkerInfo) {
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

  static Future<void> setMapStyle(BuildContext context, GoogleMapController? mapController) async {
    String style = await DefaultAssetBundle.of(context).loadString('assets/custom_map.json');
    mapController?.setMapStyle(style);
  }
}

