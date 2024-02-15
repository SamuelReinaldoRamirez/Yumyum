import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

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


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Restaurant {
//   final String name;
//   final String address;
//   final List<String> videos;

//   Restaurant({required this.name, required this.address, required this.videos});

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     return Restaurant(
//       name: json['name'],
//       address: json['address_str'],
//       videos: List<String>.from(json['video_links']),
//     );
//   }
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late Future<Restaurant> futureRestaurant;

//   @override
//   void initState() {
//     super.initState();
//     futureRestaurant = fetchRestaurant();
//   }

//   Future<Restaurant> fetchRestaurant() async {
//     final response = await http.get(Uri.parse('https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/restaurants/1'));

//     if (response.statusCode == 200) {
//       return Restaurant.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to load restaurant');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Restaurant App',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Restaurant App'),
//         ),
//         body: Center(
//           child: FutureBuilder<Restaurant>(
//             future: futureRestaurant,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Name: ${snapshot.data!.name}'),
//                     Text('Address: ${snapshot.data!.address}'),
//                     Text('Videos: ${snapshot.data!.videos.join(", ")}'), // Affichez la liste des vidéos
//                   ],
//                 );
//               } else if (snapshot.hasError) {
//                 return Text('${snapshot.error}');
//               }
//               return CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
