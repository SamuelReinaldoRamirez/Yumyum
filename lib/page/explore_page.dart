import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/providers/booking_provider.dart';
import 'map_page.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/page/search_bar.dart' as CustomSearchBar;
import 'package:yummap/widget/filter_bar.dart';
import '../pages/booking_list_page.dart';

class ExplorePage extends ConsumerWidget {
  final List<Restaurant> restaurantList;
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;
  final ValueNotifier<bool> filterFavoritesNotifier;
  final ValueNotifier<bool> ratingFilterNotifier;
  final ValueNotifier<bool> filterIsOn;
  final String? preSelectedWorkspaceId;

  ExplorePage(
      {super.key,
      required this.restaurantList,
      required this.selectedTagIdsNotifier,
      required this.selectedWorkspacesNotifier,
      required this.ratingFilterNotifier,
      required this.filterFavoritesNotifier,
      required this.filterIsOn,
      this.preSelectedWorkspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(
        "ExplorePage build avec preSelectedWorkspaceId: $preSelectedWorkspaceId");
    // Au début du build, si on a un workspace pré-sélectionné
    if (preSelectedWorkspaceId != null) {
      // Mettre à jour selectedWorkspacesNotifier avec le workspace pré-sélectionné
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedWorkspacesNotifier.value = [int.parse(preSelectedWorkspaceId!)];
      });
    }

    double screenHeight = MediaQuery.of(context).size.height;
    // Définit les hauteurs des widgets h1 et h2
    double h1 = screenHeight * 0.085; // Hauteur de la barre de recherche
    double h2 = screenHeight * 0.08; // Hauteur de la barre de filtre

    // Calcule la hauteur restante pour le dernier widget
    double h3 = screenHeight - h1 - h2;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Couleur de fond
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  // Barre de recherche avec hauteur fixe de 50px
                  SizedBox(
                    height: h1,
                    child: CustomSearchBar.SearchBar(
                      onSearchChanged: (value) {},
                      restaurantList: restaurantList,
                      selectedTagIdsNotifier: selectedTagIdsNotifier,
                      selectedWorkspacesNotifier: selectedWorkspacesNotifier,
                      filterFavoritesNotifier: filterFavoritesNotifier,
                      ratingFilterNotifier: ratingFilterNotifier,
                    ),
                  ),
                  // Barre de filtre avec hauteur fixe de 50px
                  SizedBox(
                    height: h2,
                    child: FilterBar(
                      selectedTagIdsNotifier: selectedTagIdsNotifier,
                      selectedWorkspacesNotifier: selectedWorkspacesNotifier,
                      ratingFilterNotifier: ratingFilterNotifier,
                      filterFavoritesNotifier: filterFavoritesNotifier,
                      filterIsOn: filterIsOn,
                      preSelectedWorkspaceId: preSelectedWorkspaceId,
                      onFilterChanged: (RangeValues priceRange, int rating,
                          List<String> categories) {
                        print(
                            "onFilterChanged appelé avec ${categories.length} catégories");
                        // Implémentez la logique pour gérer les changements de filtres
                      },
                    ),
                  ),
                  // Carte avec hauteur calculée
                  SizedBox(
                    height: h3,
                    child: MapPage(restaurantList: restaurantList),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 20,
            child: SizedBox(
              width: 280.0, // Largeur fixe
              height: 60.0, // Hauteur
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(bookingProvider.notifier).fetchBookings();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingListPage()),
                  );
                },
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.white,
                  size: 24,
                ),
                label: Text(
                  "Mes réservations",
                  style: AppTextStyles.paragraphWhiteStyle.copyWith(
                    fontSize: 22,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: Colors.black,
                  elevation: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
