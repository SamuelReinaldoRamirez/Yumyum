import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yummap/Restaurant.dart';
import 'package:logger/logger.dart';


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
}
