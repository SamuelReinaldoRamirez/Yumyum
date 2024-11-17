// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:yummap/helper/bottom_sheet_helper.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/constant/global.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/workspace.dart';
import 'package:yummap/model/workspace_selection_page.dart';
import 'package:latlong2/latlong.dart' as lat2;

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Restaurant> restaurantList;
  final Function(String) onSearchChanged;
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;

  const SearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.restaurantList,
    required this.selectedTagIdsNotifier,
    required this.selectedWorkspacesNotifier,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  int lastShakeTimestamp = 0;
  // static bool _filterIsOn = false;

  @override
  void dispose() {
    // Ne pas oublier de retirer l'écouteur lors de la destruction du widget
    filterIsOn.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Écouter les changements de filterIsOn
    filterIsOn.addListener(() {
      setState(() {});
    });
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
            // icon: const Icon(
            //   Icons.clear,
            //   // color: AppColors.greenishGrey,
            //   color: Colors.blueAccent,
            // ),
            icon: Container(
              decoration: filterIsOn.value
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orangeButton, // Fond orange
                    )
                  : null, // Pas de bordure si non pressé
              child: Icon(
                Icons.clear,
                color: filterIsOn.value ? Colors.white : AppColors.greenishGrey,
              ),
              padding:
                  EdgeInsets.all(4.0), // Espace entre l'icône et la bordure
            ),
            onPressed: () async {
              setState(() {
                widget.selectedWorkspacesNotifier.value = [];
                widget.selectedTagIdsNotifier.value = [];
              });
              _clearSearch(context);
              MarkerManager.resetMarkers();
              filterIsOn.value = false;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String value) async {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });

    if (value == "#hotelz") {
      // Appeler l'API Xano pour récupérer les hôtels
      try {
        final hotels = await CallEndpointService()
            .getHotelsFromXano(); // Implémenter cette méthode pour récupérer les hôtels
        if (hotels.isNotEmpty) {
          // Créer les nouveaux marqueurs pour les hôtels
          List<lat2.LatLng> hotelLocations = hotels
              .map((hotel) => lat2.LatLng(hotel.latitude, hotel.longitude))
              .toList();

          // Utiliser MapHelper pour créer les marqueurs des hôtels
          MarkerManager.markersList = MapHelper.createHotelMarkers(
            MarkerManager.context,
            hotels,
            hotelLocations,
          );

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

      return; // Terminer l'exécution pour éviter de poursuivre avec les autres logiques
    }

    // Logique pour changer l'environnement (dev/prod)
    if (value == ",dev,") {
      print("TO DEV ??");
      await CallEndpointService.switchToDev();
      value = "";
    }
    if (value == ",prod,") {
      await CallEndpointService.switchToProd();
      value = "";
    }

    // Recherche de workspaces et de restaurants
    List<Workspace> workspacesToDisplay =
        await CallEndpointService().searchWorkspaceByName(value);

    List<Restaurant> restaurantsToDisplay =
        await CallEndpointService().searchRestaurantByName(value);

    if (workspacesToDisplay.isNotEmpty) {
      // Si des workspaces sont trouvés, afficher la page de sélection
      _showWorkspaceSelectionPage(
          MarkerManager.context, workspacesToDisplay, restaurantsToDisplay);
    } else {
      // Afficher les restaurants sur la carte
      if (restaurantsToDisplay.isNotEmpty) {
        if (restaurantsToDisplay.length > 1) {
          // Plusieurs restaurants trouvés, les afficher sur la carte
          MarkerManager.createFull(MarkerManager.context, restaurantsToDisplay);
        } else {
          // Un seul restaurant trouvé, afficher son détail dans un bottom sheet
          final restaurant = restaurantsToDisplay[0];
          final latitude = restaurant.latitude;
          final longitude = restaurant.longitude;

          BottomSheetHelper.showBottomSheet(MarkerManager.context, restaurant);
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

  void _showAliasAlert(
      BuildContext context, List<String> aliasList, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(aliasList.join(', ')),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];

    // Afficher la liste mise à jour des alias
    // _showAliasAlert(context, aliasList, 'After setting');
  }

  void _handleRestaurantSelection(Restaurant restaurant) {
    BottomSheetHelper.showBottomSheet(MarkerManager.context, restaurant);
    MarkerManager.mapPageState?.mapController
        .move(lat2.LatLng(restaurant.latitude, restaurant.longitude), 15);
    MarkerManager.resetMarkers();
  }

  void _clearSearch(context) {
    MixpanelService.instance.track('ClearSearch');
    _searchController.clear();
    widget.onSearchChanged('');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
