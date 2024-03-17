import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/restaurant.dart';
import 'filter_options_modal.dart';

class SearchBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearchChanged;
  final TextEditingController _searchController = TextEditingController();

  SearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          _handleSubmitted(value);
        },
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () async {
              _clearSearch();
              List<Restaurant> newRestaurants =
                  await CallEndpointService.getRestaurantsByTags(
                      []); // Passer les identifiants de tags sélectionnés
              MarkerManager.createFull(context, newRestaurants);
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

  void _handleSubmitted(String value) {
    CallEndpointService.searchRestaurantByName(value)
        .then((List<Restaurant> newRestaurants) {
      if (newRestaurants.length > 1) {
        MarkerManager.createFull(MarkerManager.context, newRestaurants);
      } else if (newRestaurants.length == 1) {
        // Centrer la carte sur le restaurant trouvé
        final restaurant = newRestaurants[0];
        final latitude = restaurant.latitude;
        final longitude = restaurant.longitude;

        BottomSheetHelper.showBottomSheet(MarkerManager.context, restaurant);
        // Centrer la carte sur le pin du restaurant
        MarkerManager.mapPageState?.mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 13.0, // Zoom sur la position
            ),
          ),
        );
        MarkerManager.resetMarkers();
      } else {
        // Afficher un SnackBar avec le message "Aucun résultat trouvé"
        ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
          const SnackBar(
            content: Text('Aucun résultat trouvé'),
          ),
        );
      }
    }).catchError((error) {
      // Gérer les erreurs éventuelles
      print('Une erreur s\'est produite : $error');
    });
  }

  void _clearSearch() {
    _searchController.clear();
    onSearchChanged('');
  }
}
