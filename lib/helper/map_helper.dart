import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yummap/helper/bottom_sheet_helper.dart';
import 'package:yummap/model/hotel.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/page/map_page.dart';
import 'package:latlong2/latlong.dart' as lat2;

class MarkerManager {
  static List<Marker> allmarkers = [];
  static MapPageState? mapPageState;
  static List<Marker> markersList = [];
  static late BuildContext context;
  static Marker? userMarker; // Marqueur de la position de l'utilisateur

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

  // Fonction pour initialiser et mettre à jour la position de l'utilisateur
  static void startUserLocationUpdates() {
    // Initialisation immédiate de la position au démarrage
    MapHelper.getCurrentLocation((position) {
      // Mettre à jour la position de l'utilisateur avec un nouveau marqueur
      if (userMarker == null) {
        userMarker = Marker(
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
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
        addMarker(
            userMarker!); // Ajouter le marqueur de l'utilisateur à la liste
      }
      updateMap();
    });
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
  }

  static void createFull(
      BuildContext context, List<Restaurant> newRestaurants) {
    List<lat2.LatLng> newLocations = [];
    createRestaurantLocations(newRestaurants, newLocations);
    List<Marker> newMarkers = MapHelper.createListMarkers(
        context, newRestaurants, newLocations, _showMarkerInfo);
    MarkerManager.markersList = newMarkers;
  }

  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<lat2.LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(lat2.LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  static void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(context, restaurant);
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
            showMarkerInfo(context, restaurantList[i]);
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF95A472),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_dining_outlined,
                    size: 24,
                    color: Color(0xFFDDFCAD),
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

  static void createHotelLocations(
      List<Hotel> hotelList, List<lat2.LatLng> hotelLocations) {
    for (var hotel in hotelList) {
      hotelLocations.add(lat2.LatLng(hotel.latitude, hotel.longitude));
    }
  }

  static void showHotelBottomSheet(BuildContext context, Hotel hotel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 150, // Largeur maximale de l'image
                height: 150, // Hauteur maximale de l'image
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(hotel.photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(hotel.name),
              const SizedBox(height: 4),
              Text(hotel.address),
            ],
          ),
        );
      },
    );
  }

  static List<Marker> createHotelMarkers(BuildContext context,
      List<Hotel> hotelList, List<lat2.LatLng> hotelLocations) {
    List<Marker> hotelMarkers = [];

    for (int i = 0; i < hotelLocations.length; i++) {
      Marker marker = Marker(
        point: hotelLocations[i],
        builder: (ctx) => GestureDetector(
          onTap: () {
            showHotelBottomSheet(context, hotelList[i]);
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF95A472),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.hotel, // Icône spécifique pour les hôtels
                    size: 24,
                    color: Color(0xFFDDFCAD),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      hotelMarkers.add(marker);
    }

    return hotelMarkers;
  }
}
