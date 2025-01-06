import 'package:flutter/material.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              // Barre de recherche
              SizedBox(
                height: MediaQuery.of(ContextHelper.context).size.height * 0.10,
                child: CustomSearchBar.SearchBar(
                  onSearchChanged: (value) {},
                  restaurantList: restaurantList,
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              // Barre de filtre
              SizedBox(
                height: MediaQuery.of(ContextHelper.context).size.height * 0.06,
                child: FilterBar(
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              // Carte
              SizedBox(
                height: MediaQuery.of(ContextHelper.context).size.height * 0.84,
                child: MapPage(restaurantList: restaurantList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
