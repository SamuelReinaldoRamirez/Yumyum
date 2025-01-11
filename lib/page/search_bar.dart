import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:yummap/helper/bottom_sheet_helper.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/workspace.dart';
import 'package:yummap/page/workspace_selection_page.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:shared_preferences/shared_preferences.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Restaurant> restaurantList;
  final Function(String) onSearchChanged;
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;
  final ValueNotifier<bool> filterFavoritesNotifier;
  final ValueNotifier<bool> ratingFilterNotifier;

  const SearchBar({
    super.key,
    required this.onSearchChanged,
    required this.restaurantList,
    required this.selectedTagIdsNotifier,
    required this.selectedWorkspacesNotifier,
    required this.filterFavoritesNotifier,
    required this.ratingFilterNotifier,
  });

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  int lastShakeTimestamp = 0;
  ValueNotifier<bool> filterIsOn = ValueNotifier(false);

  void listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.filterFavoritesNotifier.addListener(_updateFilterIsOn);
    widget.ratingFilterNotifier.addListener(_updateFilterIsOn);
    widget.selectedTagIdsNotifier.addListener(_updateFilterIsOn);
    widget.selectedWorkspacesNotifier.addListener(_updateFilterIsOn);
  }

  @override
  void dispose() {
    widget.filterFavoritesNotifier.removeListener(_updateFilterIsOn);
    widget.ratingFilterNotifier.removeListener(_updateFilterIsOn);
    widget.selectedTagIdsNotifier.removeListener(_updateFilterIsOn);
    widget.selectedWorkspacesNotifier.removeListener(_updateFilterIsOn);
    super.dispose();
  }

  void _updateFilterIsOn() {
    bool isAnyFilterActive = widget.filterFavoritesNotifier.value ||
        widget.selectedTagIdsNotifier.value.isNotEmpty ||
        widget.selectedWorkspacesNotifier.value.isNotEmpty ||
        widget.ratingFilterNotifier.value;

    if (filterIsOn.value != isAnyFilterActive) {
      setState(() {
        filterIsOn.value = isAnyFilterActive;
      });
    }
  }

  void _clearFilters(BuildContext context) {
    print("Méthode _clearFilters appelée.");

    // Réinitialiser les filtres
    widget.filterFavoritesNotifier.value =
        false; // Désactiver le filtre des favoris
    widget.selectedTagIdsNotifier.value = [];
    widget.selectedWorkspacesNotifier.value = [];

    // Désactiver le filtre de notation
    widget.ratingFilterNotifier.value =
        false; // Assurez-vous que cela est bien ici

    _searchController.clear();

    // Réinitialiser les marqueurs
    MarkerManager.resetMarkers();

    setState(() {
      filterIsOn.value = false; // Désactiver le filtre global
    });
  }

  void _showAliasAlert(
      BuildContext context, List<String> aliasList, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: aliasList.map((alias) {
              return ListTile(
                title: Text(alias),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleWorkspaceSelection(Workspace workspace) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];

    _showAliasAlert(context, aliasList, 'After setting');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundColor,
      title: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          _handleSubmitted(value);
        },
        style: AppTextStyles.paragraphDarkStyle.copyWith(
          color: AppColors.textColor,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher dans Yummap',
          hintStyle: AppTextStyles.hintTextDarkStyle.copyWith(
            color: AppColors.textColor.withOpacity(0.5),
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textColor,
          ),
          suffixIcon: IconButton(
            icon: Container(
              decoration: filterIsOn.value
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryColor,
                    )
                  : null,
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.clear,
                color: filterIsOn.value ? Colors.white : AppColors.textColor,
              ),
            ),
            onPressed: () => _clearFilters(context),
          ),
          filled: true,
          fillColor: AppColors.backgroundColor,
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String value) async {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });

    if (value == "#hotelz") {
      try {
        final hotels = await CallEndpointService().getHotelsFromXano();
        if (hotels.isNotEmpty) {
          List<lat2.LatLng> hotelLocations = hotels
              .map((hotel) => lat2.LatLng(hotel.latitude, hotel.longitude))
              .toList();

          List<Marker> newMarkers = MapHelper.createHotelMarkers(
            MarkerManager.context,
            hotels,
            hotelLocations,
          );
          MarkerManager.swapMarkersList(newMarkers);

          MarkerManager.updateMap();
        } else {
          ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
            const SnackBar(
              content: Text('Aucun hôtel trouvé'),
            ),
          );
        }
      } catch (e) {
        print('Erreur lors de la récupération des hôtels : $e');
        ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la récupération des hôtels'),
          ),
        );
      }

      return;
    }

    if (value == ",dev,") {
      print("TO DEV ??");
      await CallEndpointService.switchToDev();
      value = "";
    }
    if (value == ",prod,") {
      await CallEndpointService.switchToProd();
      value = "";
    }

    List<Workspace> workspacesToDisplay =
        await CallEndpointService().searchWorkspaceByName(value);

    List<Restaurant> restaurantsToDisplay =
        await CallEndpointService().searchRestaurantByName(value);

    if (workspacesToDisplay.isNotEmpty) {
      _showWorkspaceSelectionPage(
          MarkerManager.context, workspacesToDisplay, restaurantsToDisplay);
    } else {
      if (restaurantsToDisplay.isNotEmpty) {
        if (restaurantsToDisplay.length > 1) {
          filterIsOn.value = true;
          setState(() {
            filterIsOn.value = true; // Désactiver le filtre global
          });
          List<Marker> newMarkers =
              await MapHelper.createMarkersFromRestaurants(
                  restaurantsToDisplay);
          MarkerManager.swapMarkersList(newMarkers);
        } else {
          final restaurant = restaurantsToDisplay[0];
          final latitude = restaurant.latitude;
          final longitude = restaurant.longitude;

          BottomSheetHelper.showDraggableBottomSheet(
              MarkerManager.context, restaurant);
          MarkerManager.mapPageState?.mapController
              .move(lat2.LatLng(latitude, longitude), 15);
          MarkerManager.resetMarkers();
        }
      } else {
        ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
          const SnackBar(
            content: Text('Aucun restaurant trouvé'),
          ),
        );
      }
    }
  }

  void _showWorkspaceSelectionPage(BuildContext context,
      List<Workspace> workspaces, List<Restaurant> restaurants) async {
    final selectedItem = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WorkspaceSelectionPage(
              workspaces: workspaces, restaurants: restaurants)),
    );

    if (selectedItem != null && selectedItem is Restaurant) {
      _handleRestaurantSelection(selectedItem);
    } else if (selectedItem != null && selectedItem is Workspace) {
      _handleWorkspaceSelection(selectedItem);
    }
  }

  void _handleRestaurantSelection(Restaurant restaurant) {
    BottomSheetHelper.showDraggableBottomSheet(
        MarkerManager.context, restaurant);
    MarkerManager.mapPageState?.mapController
        .move(lat2.LatLng(restaurant.latitude, restaurant.longitude), 15);
    MarkerManager.resetMarkers();
  }
}
