import 'package:flutter/material.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/page/restau_details.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/widget/video_carousel.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import '../constant/theme.dart';
import 'package:yummap/helper/favorite_manager.dart';

class BottomSheetHelper {
  static void showDraggableBottomSheet(
      BuildContext context, Restaurant restaurant) {
    final favoriteState = ValueNotifier<bool>(false);

    // Initialiser l'état
    FavoriteManager.isFavorite(restaurant).then((value) {
      favoriteState.value = value;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.60,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 3.0,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barre draggable
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),

                      // Header Section
                      Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(
                                  restaurant.name,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleDarkStyle.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.ratings.toString(),
                                      style: AppTextStyles.hintTextDarkStyle
                                          .copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGrey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    restaurant.cuisine,
                                    style: AppTextStyles.hintTextWhiteStyle
                                        .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: favoriteState,
                            builder: (context, isFavorite, child) {
                              return FloatingActionButton(
                                onPressed: () async {
                                  // Toggle le restaurant en favori
                                  bool newFavoriteState =
                                      await FavoriteManager.toggleFavorite(
                                          restaurant);
                                  favoriteState.value = newFavoriteState;
                                },
                                backgroundColor: AppColors.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // Rendre le bouton rond
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      VideoCarousel(videoLinks: restaurant.videoLinks),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomNeuButton(
                            onPressed: () {
                              _navigateToTags(context, restaurant);
                            },
                            text: "Voir plus",
                            icon: Icons.info_outlined,
                            buttonColor: AppColors.primaryColor,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  static void _navigateToTags(BuildContext context, Restaurant restaurant) {
    MixpanelService.instance.track('DetailsResto', properties: {
      'resto_id': restaurant.id,
      'resto_name': restaurant.name,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsWidget(restaurant: restaurant),
      ),
    );
  }
}
