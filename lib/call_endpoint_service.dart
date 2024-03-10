import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yummap/Restaurant.dart';
import 'package:logger/logger.dart';
import 'package:yummap/tag.dart';


class CallEndpointService {
  

  static const String baseUrl =
      'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/restaurants';

  static Future<List<Restaurant>> getRestaurantsFromXanos() async {
    final logger = Logger();
    logger.d('XANOS**********************');
    // logger.i('This is an info message');
    // logger.w('This is a warning message');
    // logger.e('This is an error message');
    // logger.wtf('This is a terrible failure message');
    try {
      final response = await http.get(Uri.parse(baseUrl));
      // logger.e('This is an error message');
      // logger.e(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // logger.e(response.body);


        List<Restaurant> restaurants = jsonData.map((data) {
          // logger.e(data);

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

  static const String allTagsUrl = 'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/tags';

  static Future<List<Tag>> getTagsFromXanos() async {
    final logger = Logger();

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

  // static const String tagByIdUrl = 'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/tags/{tags_id}';

  // static Future<Tag> getTagByIdFromXanos() async {
  //   final logger = Logger();

  //   try {
  //     final response = await http.get(Uri.parse(tagByIdUrl));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);


  //       Tag tag = jsonData.map((data) {
  //         // logger.e(data);

  //         return Tag.fromJson(data);
  //       }).first;

  //       return tag;
  //     } else {
  //       throw Exception('Failed to load tag');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load tag: $e');
  //   }
  // }
}
