// import 'package:flutter/material.dart';
// import 'package:yummap/restaurant.dart';
// import 'package:yummap/review_interface.dart';

// class ReviewDetailsWidget extends StatefulWidget {
//   const ReviewDetailsWidget(
//       {Key? key, required this.restaurant, required this.reviews})
//       : super(key: key);
//   final Restaurant restaurant;
//   final List<ReviewInterface> reviews;

//   @override
//   _ReviewDetailsWidgetState createState() =>
//       _ReviewDetailsWidgetState(restaurant, reviews);
// }

// class _ReviewDetailsWidgetState extends State<ReviewDetailsWidget> {
//   Restaurant restaurant;
//   List<ReviewInterface> _reviews = [];
//   final bool _isLoading = false;

//   _ReviewDetailsWidgetState(this.restaurant, this._reviews);

//   @override
//   void initState() {
//     super.initState();
//     if (_reviews.isEmpty) {
//       _fetchRestaurantDetails();
//     }
//   }

//   Future<void> _fetchRestaurantDetails() async {
//     // Votre logique de récupération des avis depuis l'API Google Places
//   }

//   Widget _buildStarRating(double rating) {
//     List<Widget> stars = [];
//     for (int i = 1; i <= 5; i++) {
//       stars.add(
//         Icon(
//           i <= rating ? Icons.star : Icons.star_border,
//           color: Colors.amber,
//           size: 20,
//         ),
//       );
//     }
//     return Row(children: stars);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_reviews.isNotEmpty ? 'Avis ${_reviews[0].type}' : 'Avis'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: widget.reviews.length,
//               itemBuilder: (context, index) {
//                 final review = widget.reviews[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8.0),
//                   elevation: 4,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Auteur: ${review.author}',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8.0),
//                         _buildStarRating(review.rating),
//                         const SizedBox(height: 8.0),
//                         Text(
//                           'Avis:',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4.0),
//                         Text(
//                           review.comment,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/review_interface.dart';

class ReviewDetailsWidget extends StatefulWidget {
  const ReviewDetailsWidget(
      {Key? key, required this.restaurant, required this.reviews})
      : super(key: key);
  final Restaurant restaurant;
  final List<ReviewInterface> reviews;

  @override
  _ReviewDetailsWidgetState createState() =>
      _ReviewDetailsWidgetState(restaurant, reviews);
}

class _ReviewDetailsWidgetState extends State<ReviewDetailsWidget> {
  Restaurant restaurant;
  List<ReviewInterface> _reviews = [];
  final bool _isLoading = false;

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

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      );
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_reviews.isNotEmpty ? "${_reviews[0].type}".tr() : ""),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStarRating(review.rating),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          review.comment,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            review.author,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

