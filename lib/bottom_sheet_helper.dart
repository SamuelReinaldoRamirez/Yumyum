import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restau_details.dart';
import 'package:yummap/restaurant.dart';
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
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(), // Première colonne vide
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Text(
                              restaurant.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF646165),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber, // Couleur de l'étoile
                                ),
                                Text(
                                  restaurant.ratings
                                      .toString(), // Affichage de la note du restaurant
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    Color(0xFF646165), // Couleur de la pastille
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                restaurant.cuisine,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ), // Deuxième colonne avec champ texte
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline),
                          iconSize: 40,
                          color: Color(0xFF95A472),
                          onPressed: () {
                            _navigateToTags(context, restaurant);
                          },
                        ),
                      ), // Troisième colonne avec bouton
                    ),
                  ],
                ),
                // Text(
                //   restaurant.name,
                //   style: const TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black54,
                //   ),
                // ),
                const SizedBox(height: 8),

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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _navigateToTags(context, restaurant);
                    //   },
                    //   child: const Text("Tags"),
                    // ),
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
    MixpanelService.instance.track('MoveToResto', properties: {
      'resto_id': restaurant.id,
      'resto_name': restaurant.name,
    });

    final String url =
        'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
    final Uri uri = Uri.parse(url);

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceSafariVC: false);
    } else {
      final String fallbackUrl =
          'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
      final Uri fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunch(fallbackUri.toString())) {
        await launch(fallbackUri.toString());
      } else {
        print('Could not launch the map.');
      }
    }
  }

  static void _navigateToTags(BuildContext context, Restaurant restaurant) {
    MixpanelService.instance.track('DetailsResto', properties: {
      'resto_id': restaurant.id,
      'resto_name': restaurant.name,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          // builder: (context) => RestaurantDetailsWidget()),
          builder: (context) =>
              RestaurantDetailsWidget(restaurant: restaurant)),
      // builder: (context) => DetailsTags(restaurant: restaurant)),
    );
  }
}
