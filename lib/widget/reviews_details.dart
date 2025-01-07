import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/model/review_interface.dart';

class ReviewDetailsWidget extends StatefulWidget {
  const ReviewDetailsWidget({
    super.key,
    required this.restaurant,
    required this.reviews,
  });

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
    // Logique de récupération des avis
  }

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: AppColors.primaryColor,
          size: 20,
        ),
      );
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _reviews.isNotEmpty ? 'Avis ${_reviews[0].type}' : 'Avis',
          style: AppTextStyles.titleDarkStyle.copyWith(
            fontSize: 24,
            color: AppColors.textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.secondaryColor,
                              child: Text(
                                review.author[0].toUpperCase(),
                                style: AppTextStyles.titleDarkStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.author,
                                    style:
                                        AppTextStyles.titleDarkStyle.copyWith(
                                      fontSize: 16,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: _buildStarRating(review.rating),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (review.comment.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              review.comment,
                              style: AppTextStyles.paragraphDarkStyle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
