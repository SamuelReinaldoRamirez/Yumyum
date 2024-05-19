import 'package:flutter/material.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/theme.dart';
import 'filter_options_modal.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Restaurant> restaurantList;
  final Function(String) onSearchChanged;

  SearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.restaurantList,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  static const double shakeThresholdGravity = 2.7;
  static const int shakeSlopTimeMs = 500;
  int lastShakeTimestamp = 0;

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent event) {
      final now = DateTime.now().millisecondsSinceEpoch;

      if ((now - lastShakeTimestamp) > shakeSlopTimeMs) {
        final gX = event.x / 9.81;
        final gY = event.y / 9.81;
        final gZ = event.z / 9.81;

        final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          lastShakeTimestamp = now;
          _onShake();
        }
      }
    });
  }

  void _onShake() {
    Random random = Random();
    int randomIndex = random.nextInt(widget.restaurantList.length);
    FocusScope.of(context).requestFocus(FocusNode());
    BottomSheetHelper.showBottomSheet(MarkerManager.context, widget.restaurantList[randomIndex]);
  }

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
        final restaurant = newRestaurants[0];
        final latitude = restaurant.latitude;
        final longitude = restaurant.longitude;

        BottomSheetHelper.showBottomSheet(MarkerManager.context, restaurant);
        MarkerManager.mapPageState?.mapController
            .move(lat2.LatLng(latitude, longitude), 15);
        MarkerManager.resetMarkers();
      } else {
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
    widget.onSearchChanged('');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
