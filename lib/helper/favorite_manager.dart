import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/favorite_restaurant.dart';

class FavoriteManager {
  static const String _favoritesKey = 'favorites';

  // Sauvegarder un restaurant favori
  static Future<void> saveFavorite(FavoriteRestaurant restaurant) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoritesIds();
    
    if (!favorites.contains(restaurant.id)) {
      favorites.add(restaurant.id);
      await prefs.setStringList(_favoritesKey, favorites);
      
      // Sauvegarder les détails du restaurant
      await prefs.setString(
        'restaurant_${restaurant.id}',
        jsonEncode(restaurant.toJson())
      );
    }
  }

  // Retirer un restaurant des favoris
  static Future<void> removeFavorite(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoritesIds();
    
    favorites.remove(restaurantId);
    await prefs.setStringList(_favoritesKey, favorites);
    await prefs.remove('restaurant_${restaurantId}');
  }

  // Vérifier si un restaurant est favori
  static Future<bool> isFavorite(String restaurantId) async {
    List<String> favorites = await getFavoritesIds();
    return favorites.contains(restaurantId);
  }

  // Obtenir la liste des IDs des restaurants favoris
  static Future<List<String>> getFavoritesIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Obtenir tous les restaurants favoris
  static Future<List<FavoriteRestaurant>> getAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = await getFavoritesIds();
    List<FavoriteRestaurant> favorites = [];

    for (String id in favoriteIds) {
      String? restaurantJson = prefs.getString('restaurant_${id}');
      if (restaurantJson != null) {
        favorites.add(
          FavoriteRestaurant.fromJson(jsonDecode(restaurantJson))
        );
      }
    }

    return favorites;
  }
}
