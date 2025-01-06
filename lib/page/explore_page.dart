import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'map_page.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/page/search_bar.dart' as CustomSearchBar;
import 'package:yummap/widget/filter_bar.dart';
import 'package:yummap/helper/context_helper.dart';

class ExplorePage extends StatelessWidget {
  final List<Restaurant> restaurantList;

  ExplorePage({Key? key, required this.restaurantList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Définition des hauteurs fixes
    const double searchBarHeight =
        50.0; // hauteur fixe pour la barre de recherche
    const double filterBarHeight =
        50.0; // hauteur fixe pour la barre de filtres

    // Calcul de la hauteur disponible pour la carte
    final double screenHeight = MediaQuery.of(context).size.height;
    final double mapHeight = screenHeight - searchBarHeight - filterBarHeight;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              // Barre de recherche
              SizedBox(
                height: searchBarHeight,
                child: CustomSearchBar.SearchBar(
                  onSearchChanged: (value) {},
                  restaurantList: restaurantList,
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              // Barre de filtre
              SizedBox(
                height: filterBarHeight,
                child: FilterBar(
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              // Carte
              SizedBox(
                height: mapHeight,
                child: MapPage(restaurantList: restaurantList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
