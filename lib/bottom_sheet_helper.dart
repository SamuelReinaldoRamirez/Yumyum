import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/details_tags.dart';
import 'package:yummap/video_carousel.dart';

class BottomSheetHelper {
  static void showBottomSheet(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                VideoCarousel(videoLinks: restaurant.videoLinks),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _navigateToRestaurant(restaurant);
                      },
                      child: const Text("Y aller"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToTags(context, restaurant);
                      },
                      child: const Text("Tags"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  static void _navigateToRestaurant(Restaurant restaurant) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      //print('Could not launch $url');
    }
  }

  static void _navigateToTags(BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailsTags(restaurant: restaurant)),
    );
  }
}
