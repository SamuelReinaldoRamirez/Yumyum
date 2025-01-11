import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yummap/model/restaurant.dart';
import 'opening_hours_helper.dart';

class RestaurantStatusManager {
  static Timer? _updateTimer;
  static final ValueNotifier<Map<String, bool>> restaurantOpenStatus =
      ValueNotifier({});

  /// Démarre la mise à jour périodique des statuts
  static void startPeriodicUpdates(List<Restaurant> restaurants) {
    // Mise à jour initiale
    _updateRestaurantsStatus(restaurants);

    // Configurer le timer pour les mises à jour toutes les 30 minutes
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _updateRestaurantsStatus(restaurants);
    });
  }

  /// Arrête les mises à jour périodiques
  static void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Met à jour le statut de tous les restaurants
  static void _updateRestaurantsStatus(List<Restaurant> restaurants) {
    final Map<String, bool> newStatus = {};
    for (var restaurant in restaurants) {
      newStatus[restaurant.id.toString()] =
          OpeningHoursHelper.isRestaurantOpen(restaurant);
    }
    restaurantOpenStatus.value = newStatus;
  }

  /// Vérifie si un restaurant spécifique est ouvert
  static bool isRestaurantOpen(String restaurantId) {
    return restaurantOpenStatus.value[restaurantId] ?? false;
  }
}
