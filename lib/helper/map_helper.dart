import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/helper/bottom_sheet_helper.dart';
import 'package:yummap/helper/opening_hours_helper.dart';
import 'package:yummap/model/hotel.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/page/map_page.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:yummap/widget/restaurant_pin_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MarkerManager {
  static List<Marker> allmarkers = [];
  static MapPageState? mapPageState;
  static List<Marker> markersList = [];
  static late BuildContext context;
  static Marker? userMarker; // Marqueur de la position de l'utilisateur
  static List<Marker> favoriteMarkers = [];

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
    MapHelper.createFull(context, newRestaurants);
    updateMap();
  }

  static void resetMarkers() {
    markersList = List<Marker>.from(allmarkers);
    print("MarkersList length: ${markersList.length}");
    updateMap();
  }

  static void swapMarkersList(List<Marker> newMarkers) {
    // Nettoyage de l'ancienne liste pour éviter les fuites
    markersList.clear();

    // Assigne la nouvelle liste en créant une nouvelle référence
    markersList = List<Marker>.from(newMarkers);
    print("MarkersList length: ${markersList.length}");

    // Met à jour la carte pour afficher les nouveaux markers
    updateMap();
  }

  static void addRestaurantMarker(Restaurant restaurant) {
    // Create a marker for the restaurant
    final marker = Marker(
      point: lat2.LatLng(restaurant.latitude, restaurant.longitude),
      builder: (ctx) => Container(
        child: Icon(Icons.restaurant,
            color: Colors.red), // Customize the marker icon
      ),
    );
    // Add the marker to the markers list
    addMarker(marker);
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

  static Future<void> saveFavoriteMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> markersData = favoriteMarkers.map((marker) {
      return jsonEncode({
        'latitude': marker.point.latitude,
        'longitude': marker.point.longitude,
      });
    }).toList();
    await prefs.setStringList('favorite_markers', markersData);
  }

  static Future<void> loadFavoriteMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? markersData = prefs.getStringList('favorite_markers');
    if (markersData != null) {
      favoriteMarkers.clear();
      for (String markerData in markersData) {
        Map<String, dynamic> data = jsonDecode(markerData);
        favoriteMarkers.add(Marker(
          point: lat2.LatLng(data['latitude'], data['longitude']),
          builder: (ctx) => Container(
            child: Icon(Icons.restaurant,
                color: Colors.red), // Customize the marker icon
          ),
        ));
      }
    }
  }

  // Méthode pour nettoyer complètement lors de la fermeture de l'app
  static void dispose() {
    // Nettoyage de toutes les listes sans essayer de modifier les builders
    allmarkers.clear();
    markersList.clear();
    favoriteMarkers.clear();
    userMarker = null;
    mapPageState = null;
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

  static Future<void> createFull(
      BuildContext context, List<Restaurant> newRestaurants) async {
    List<lat2.LatLng> newLocations = [];
    createRestaurantLocations(newRestaurants, newLocations);

    // Créer la nouvelle liste de markers
    List<Marker> newMarkers =
        await createMarkersFromRestaurants(newRestaurants);

    // Utiliser la nouvelle méthode de swap
    MarkerManager.swapMarkersList(newMarkers);
  }

  static void createRestaurantLocations(
      List<Restaurant> restaurantList, List<lat2.LatLng> restaurantLocations) {
    for (var restaurant in restaurantList) {
      restaurantLocations
          .add(lat2.LatLng(restaurant.latitude, restaurant.longitude));
    }
  }

  static void showMarkerInfo(BuildContext context, Restaurant restaurant) {
    BottomSheetHelper.showDraggableBottomSheet(context, restaurant);
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

  static Future<List<Marker>> createMarkersFromRestaurants(
      List<Restaurant> restaurants) async {
    List<Marker> markers = [];
    for (var restaurant in restaurants) {
      markers.add(createPinFromRestaurant(restaurant));
    }
    return markers;
  }

  static Marker createPinFromRestaurant(Restaurant restaurant) {
    bool isOpen = OpeningHoursHelper.isRestaurantOpen(restaurant);
    return Marker(
      point: lat2.LatLng(restaurant.latitude, restaurant.longitude),
      builder: (ctx) => GestureDetector(
        onTap: () => showMarkerInfo(ctx, restaurant),
        child: RestaurantPinGenerator.buildPinIcon(
            restaurant.cuisine, isOpen, Colors.white, AppColors.secondaryColor),
      ),
    );
  }
}
