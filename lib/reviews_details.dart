import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';

class ReviewDetailsWidget extends StatefulWidget {
  const ReviewDetailsWidget({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _ReviewDetailsWidgetState createState() =>
      _ReviewDetailsWidgetState(restaurant);
}

class _ReviewDetailsWidgetState extends State<ReviewDetailsWidget> {
  Restaurant restaurant;
  List<Review> _reviews = [];
  bool _isLoading = false;

  _ReviewDetailsWidgetState(this.restaurant);

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  Future<void> _fetchRestaurantDetails() async {
    // Remplacez YOUR_API_KEY par votre clé d'API Google
    print('apiKEY EN DUR ?????');
    String apiKey = 'AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U';
    // Remplacez YOUR_PLACE_ID par l'identifiant unique du lieu "Bao Express"
    // String placeId = 'ChIJ2SnopiVt5kcRCpl04SjBTuY';
        String placeId = restaurant.placeId;


    // URL de l'endpoint "Place Details"
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=reviews&key=$apiKey';

    setState(() {
      _isLoading = true;
    });

    try {
      // Faire la requête HTTP
      http.Response response = await http.get(Uri.parse(url));

      // Vérifier si la requête a été réussie
      if (response.statusCode == 200) {
        // Analyser la réponse JSON
        Map<String, dynamic> data = json.decode(response.body);
        // Extraire les avis
        List<dynamic> reviews = data['result']['reviews'];
        // Mettre à jour la liste des avis
        setState(() {
          _reviews = reviews.map((review) => Review.fromJson(review)).toList();
          _isLoading = false;
        });
      } else {
        print('Erreur lors de la requête: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erreur lors de la requête: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avis Google'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  title: Text('Auteur: ${review.authorName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Note: ${review.rating}'),
                      Text('Avis: ${review.text}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class Review {
  final String authorName;
  final double rating;
  final String text;

  Review({required this.authorName, required this.rating, required this.text});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'],
      rating: json['rating'].toDouble(),
      text: json['text'],
    );
  }
}
