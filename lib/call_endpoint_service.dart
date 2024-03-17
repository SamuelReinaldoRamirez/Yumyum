import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yummap/restaurant.dart';
import 'package:logger/logger.dart';
import 'package:yummap/tag.dart';

class CallEndpointService {
  static const String baseUrl =
      'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/restaurants';

  static Future<List<Restaurant>> getRestaurantsFromXanos() async {
    final logger = Logger();
    logger.d('XANOS**********************');
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Restaurant> restaurants = jsonData.map((data) {
          return Restaurant.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  static const String allTagsUrl =
      'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/tags';

  static Future<List<Tag>> getTagsFromXanos() async {
    try {
      final response = await http.get(Uri.parse(allTagsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Tag> tags = jsonData.map((data) {
          // logger.e(data);

          return Tag.fromJson(data);
        }).toList();

        return tags;
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      throw Exception('Failed to load tags: $e');
    }
  }

  static Future<List<Restaurant>> getRestaurantsByTags(List<int> tagsId) async {
    // Convertir la liste d'entiers en une chaîne de requête
    String tagsIdQueryString = jsonEncode({'tags_id': tagsId});

    String url = '$baseUrl/tags/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: tagsIdQueryString,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Restaurant> restaurants = jsonData.map((data) {
          return Restaurant.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to load restaurants by tags');
      }
    } catch (e) {
      throw Exception('Failed to load restaurants by tags: $e');
    }
  }

  static Future<List<Restaurant>> searchRestaurantByName(
      String restaurantName) async {
    final String endpoint =
        'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/restaurants/search/$restaurantName';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Restaurant> restaurants = jsonData.map((data) {
          return Restaurant.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to search restaurants by name');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants by name: $e');
    }
  }
}
