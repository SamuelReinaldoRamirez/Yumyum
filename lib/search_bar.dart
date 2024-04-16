import 'package:flutter/material.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/theme.dart';
import 'filter_options_modal.dart';
import 'package:latlong2/latlong.dart' as lat2;

class SearchBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearchChanged;
  final TextEditingController _searchController = TextEditingController();

  SearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          _handleSubmitted(value);
        },
        style: AppTextStyles.paragraphDarkStyle,
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant',
          hintStyle: AppTextStyles.hintTextDarkStyle,
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.greenishGrey,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.clear,
              color: AppColors.greenishGrey,
            ),
            onPressed: () async {
              _clearSearch(context);
              MarkerManager.resetMarkers();
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return const FilterOptionsModal();
              },
            );
          },
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orangeButton,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmitted(String value) {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });
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
        MarkerManager.mapPageState?.mapController
            .move(lat2.LatLng(latitude, longitude), 15);
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
      //print('Une erreur s\'est produite : $error');
    });
  }

  void _clearSearch(context) {
    MixpanelService.instance.track('ClearSearch');
    _searchController.clear();
    onSearchChanged('');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
