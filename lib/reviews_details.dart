import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';

class ReviewDetailsWidget extends StatefulWidget {
  const ReviewDetailsWidget(
      {Key? key, required this.restaurant, required this.reviews})
      : super(key: key);
  final Restaurant restaurant;
  final List<ReviewRestau> reviews;

  @override
  _ReviewDetailsWidgetState createState() =>
      _ReviewDetailsWidgetState(restaurant, reviews);
}

class _ReviewDetailsWidgetState extends State<ReviewDetailsWidget> {
  Restaurant restaurant;
  List<ReviewRestau> _reviews = [];
  bool _isLoading = false;

  _ReviewDetailsWidgetState(this.restaurant, this._reviews);

  @override
  void initState() {
    super.initState();
    if (_reviews.isEmpty) {
      _fetchRestaurantDetails();
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    // Votre logique de récupération des avis depuis l'API Google Places
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis Google'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return ListTile(
                  title: Text('Auteur: ${review.author}'),
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
