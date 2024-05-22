import 'package:flutter/material.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace.dart';
import 'package:yummap/workspace_selection_page.dart';
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
          hintText: 'Rechercher dans Yummap',
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

    Future<void> _handleSubmitted(String value) async {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });

    List<Workspace> workspacesToDisplay = await CallEndpointService.searchWorkspaceByName(value);

    List<Restaurant> restaurantsToDisplay = await CallEndpointService.searchRestaurantByName(value);

      if(workspacesToDisplay.isNotEmpty ){
        _showWorkspaceSelectionPage(context, workspacesToDisplay, restaurantsToDisplay);
      }else{
        if (restaurantsToDisplay.length > 1) {
            MarkerManager.createFull(MarkerManager.context, restaurantsToDisplay);
          } else if (restaurantsToDisplay.length == 1) {
            final restaurant = restaurantsToDisplay[0];
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
      }
  ///
  }

  void _showWorkspaceSelectionPage(BuildContext context, List<Workspace> workspaces, List<Restaurant> restaurants) async {
    final selectedItem  = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkspaceSelectionPage(workspaces: workspaces, restaurants: restaurants)),
    );

   
    if (selectedItem != null && selectedItem is Restaurant) {
      _handleRestaurantSelection(selectedItem);
    } else if (selectedItem != null && selectedItem is Workspace) {
      _handleWorkspaceSelection(selectedItem);
    }
  }

   void _handleWorkspaceSelection(Workspace workspace) async {
  // Récupérer les restaurants à partir des placeId
  List<String> placeIds = workspace.restaurants_placeId;
  List<Restaurant> restaurants = await CallEndpointService.searchRestaurantsByPlaceIDs(placeIds);

  if (restaurants.isNotEmpty) {
    // Afficher les restaurants sur la carte
    MarkerManager.createFull(MarkerManager.context, restaurants);
  } else {
    ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
      const SnackBar(
        content: Text('Aucun restaurant trouvé pour ce workspace'),
      ),
    );
  }
}


  void _handleRestaurantSelection(Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(MarkerManager.context, restaurant);
    MarkerManager.mapPageState?.mapController
        .move(lat2.LatLng(restaurant.latitude, restaurant.longitude), 15);
    MarkerManager.resetMarkers();
  }



//   void _showWorkspaceDropdown(List<Workspace> workspaces) async {
//   final selectedWorkspace = await showDialog<Workspace>(
//     context: context,
//     builder: (BuildContext context) {
//       return SimpleDialog(
//         title: Text('Sélectionnez un workspace'),
//         children: workspaces.map((workspace) {
//           return SimpleDialogOption(
//             onPressed: () {
//               Navigator.pop(context, workspace);
//             },
//             child: Text(workspace.name),
//           );
//         }).toList(),
//       );
//     },
//   );

//   if (selectedWorkspace != null) {
//     _handleWorkspaceSelection(selectedWorkspace);
//   }
// }

  void _clearSearch(context) {
    MixpanelService.instance.track('ClearSearch');
    _searchController.clear();
    widget.onSearchChanged('');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
