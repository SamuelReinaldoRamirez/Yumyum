import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/restaurant.dart';

class FavoriteManager {
  static const String _favoritesKey = 'favorites';
  static List<Restaurant> favoriteRestaurants = [];

  // Toggle le restaurant en favori
  static Future<bool> toggleFavorite(Restaurant restaurant) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoritesIds();

    String restaurantId = restaurant.id.toString();

    if (favorites.contains(restaurantId)) {
      // Retirer du favoris
      favorites.remove(restaurantId);
      await prefs.setStringList(_favoritesKey, favorites);
      await prefs.remove('restaurant_${restaurantId}'); // Retirer les détails du restaurant
      favoriteRestaurants.removeWhere((element) => element.id == restaurant.id);
      return false; // Restaurant n'est plus favori
    } else {
      // Ajouter aux favoris
      favorites.add(restaurantId);
      await prefs.setStringList(_favoritesKey, favorites);
      await prefs.setString('restaurant_${restaurantId}', jsonEncode(restaurant.toJson()));
      favoriteRestaurants.add(restaurant);
      return true; // Restaurant est maintenant favori
    }
  }

  // Obtenir la liste des IDs des restaurants favoris
  static Future<List<String>> getFavoritesIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Vérifier si un restaurant est favori
  static Future<bool> isFavorite(Restaurant restaurant) async {
    List<String> favorites = await getFavoritesIds();
    return favorites.contains(restaurant.id
        .toString()); // Vérifier si l'ID est dans la liste des favoris
  }

  // Charger les restaurants favoris
  static Future<void> loadFavoriteRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favoriteIds = await getFavoritesIds();
    favoriteRestaurants = [];

    for (String id in favoriteIds) {
      String? restaurantJson = prefs.getString('restaurant_${id}');
      if (restaurantJson != null) {
        favoriteRestaurants
            .add(Restaurant.fromJson(jsonDecode(restaurantJson)));
      }
    }
  }

  // Obtenir la liste des restaurants favoris depuis la mémoire
  static Future<List<Restaurant>> getFavoriteRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = await getFavoritesIds();
    List<Restaurant> favoriteRestaurants = [];

    for (String id in favoriteIds) {
      String? restaurantJson = prefs.getString('restaurant_${id}');
      if (restaurantJson != null) {
        favoriteRestaurants.add(Restaurant.fromJson(jsonDecode(restaurantJson)));
      }
    }

    return favoriteRestaurants;
  }
}
