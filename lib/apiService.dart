import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

//appelé nulle part? 
  Future<dynamic> fetchData() async {
    try {
      var response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        // Convertir la réponse JSON en objet Dart
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}