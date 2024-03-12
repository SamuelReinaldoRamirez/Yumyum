import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/restaurant.dart';
import 'filter_options_modal.dart';

class SearchBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearchChanged;

  const SearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () async {
              // Effacer le texte de recherche
              // Appliquer les filtres et fermer le modal
              List<Restaurant> newRestaurants =
                  await CallEndpointService.getRestaurantsByTags(
                      []); // Passer les identifiants de tags sélectionnés
              MarkerManager.createFull(context, newRestaurants);
              //Navigator.of(context).pop();
              onSearchChanged('');
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return FilterOptionsModal();
              },
            );
          },
        ),
      ],
    );
  }
}
