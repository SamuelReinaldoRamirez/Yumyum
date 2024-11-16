import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/model/restau_details.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/widget/video_carousel.dart';
import '../constants/theme.dart';

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
                              style: AppTextStyles.titleDarkStyle,
                              maxLines: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color:
                                      AppColors.orangeBG, // Couleur de l'étoile
                                ),
                                Text(
                                    restaurant.ratings
                                        .toString(), // Affichage de la note du restaurant
                                    style: AppTextStyles.hintTextDarkStyle),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .darkGrey, // Couleur de la pastille
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(restaurant.cuisine,
                                  style: AppTextStyles.hintTextWhiteStyle),
                            ),
                          ],
                        ),
                      ), // Deuxième colonne avec champ texte
                    ),

                    // FloatingActionButton(
                    //   onPressed: () {
                    //     _navigateToTags(context, restaurant);
                    //   },
                    //   backgroundColor: const Color(0xFF95A472),
                    //   child: const Icon(
                    //     Icons.info_outline,
                    //     color: Colors.white, // Couleur de l'icône en blanc
                    //     size: 30, // Ajuste la taille de l'icône si nécessaire
                    //   ),
                    // ),

                    FloatingActionButton(
                      onPressed: () {
                        _navigateToTags(context, restaurant);
                      },
                      backgroundColor: const Color(0xFF95A472),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            50), // Définit le bouton comme rond
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white, // Couleur de l'icône en blanc
                        size: 30, // Ajuste la taille de l'icône si nécessaire
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                VideoCarousel(videoLinks: restaurant.videoLinks),
                const SizedBox(height: 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _navigateToRestaurant(restaurant);
                      },
                      style: AppButtonStyles.elevatedButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Y aller"),
                          const SizedBox(
                              width: 8), // Espacement entre l'icône et le texte

                          Transform.rotate(
                            angle: 90 * 3.141592653589793 / 180,
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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

    if (await canLaunchUrl(uri)) {
      await launch(uri.toString(), forceSafariVC: false);
    } else {
      final String fallbackUrl =
          'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}';
      final Uri fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      } else {
        //print('Could not launch the map.');
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
