// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/filter_options_modal.dart';
import 'package:yummap/global.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace.dart';
import 'package:yummap/workspace_selection_page.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SearchBarState createState() => SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  static const double shakeThresholdGravity = 2.7;
  static const int shakeSlopTimeMs = 500;
  int lastShakeTimestamp = 0;


@override
  void dispose() {
    // Ne pas oublier de retirer l'écouteur lors de la destruction du widget
    filterIsOn.removeListener(() {});
    super.dispose();
  }

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
    // Écouter les changements de filterIsOn
    filterIsOn.addListener(() {
      setState(() {});
    });
  }

  void _onShake() {
    Random random = Random();
    int randomIndex = random.nextInt(widget.restaurantList.length);
    FocusScope.of(context).requestFocus(FocusNode());
    BottomSheetHelper.showBottomSheet(
        MarkerManager.context, widget.restaurantList[randomIndex]);
  }


  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  // ValueNotifier<bool> showWorCircleFilterInSearchBar 
  // = ValueNotifier<bool>(true); 
  // = ValueNotifier<bool>(showWorkspaceOptionModalBool && _overlayEntry != null); 
  //rendre non visible ET NON CLICKABLE ssi 1) on vient de le cliquer et on est abonné à des wkspaces
  bool showWorkspaceOptionModalBool = hasSubscription.value;

  void _showOverlay(BuildContext context) {
    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + renderBox.size.height,
        width: MediaQuery.of(context).size.width, // Vous pouvez ajuster la largeur ici
        child: Material(
          elevation: 1.0,
          child: Container(
            color: Colors.white10, // Couleur de fond du widget de filtre
            // color: Colors.grey[200], // Couleur de fond du widget de filtre
            padding: EdgeInsets.all(10),
            child: FilterBar(
              selectedTagIdsNotifier: selectedTagIdsNotifier,
              selectedWorkspacesNotifier: selectedWorkspacesNotifier,
            ), // Remplacez ceci par votre widget
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        key: _buttonKey,
        // onTap: () {
        onTap: !(showWorCircleFilterInSearchBar.value)
                ? null
                : () {
          //si on n'est pas abonné, on veut juste ouvrir la bottomsheet des filtres
          if(!showWorkspaceOptionModalBool){
            //show bottomsheetfiltre
            showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterOptionsModal(
                      initialSelectedTagIds:
                          widget.selectedTagIdsNotifier.value,
                      onApply: (selectedIds) {
                        setState(() {
                          widget.selectedTagIdsNotifier.value = selectedIds;
                        });
                      },
                      parentState: FilterBarState(),
                    );
                  },
                );
          }else{
            if (_overlayEntry == null) {
              _showOverlay(context);
              // showWorCircleFilterInSearchBar.value = !showWorCircleFilterInSearchBar.value;          
            } 
            // else {
            //   removeOverlay();
            //   // showWorCircleFilterInSearchBar.value = !showWorCircleFilterInSearchBar.value;          
            // }
          }
        },
        borderRadius: BorderRadius.circular(50), // Assurez-vous que l'effet d'onde soit circulaire
        child: 


        ValueListenableBuilder<bool>(
              valueListenable: showWorCircleFilterInSearchBar,
              builder: (context, show, child) {
                return Visibility(
                  visible: show,
                  child:


        Container(
          width: MediaQuery.of(context).size.width * (8 / 100), // Largeur du bouton
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orangeButton, // Fond orange
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Couleur de l'ombre
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2), // Décalage de l'ombre
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4), // Réduire l'espace autour de l'icône
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 25, // Taille de l'icône
              ),
            ),
          ),
        ),


                );
                },
                ),


      ),
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
        icon: Container(
          decoration: filterIsOn.value
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                )
              : null,
          child: Icon(
            Icons.clear,
            color: AppColors.greenishGrey,
          ),
          padding: EdgeInsets.all(4.0),
        ),
        onPressed: () async {
          setState(() {
            // widget.selectedWorkspacesNotifier.value = [];
            // widget.selectedTagIdsNotifier.value = [];
            selectedWorkspacesNotifier.value = [];
            selectedTagIdsNotifier.value = [];
          });
          _clearSearch(context);
          MarkerManager.resetMarkers();
          filterIsOn.value = false;
        },
      ),
    ),
  ),
  actions: [
    // Si vous souhaitez ajouter d'autres actions à droite, vous pouvez le faire ici.
  ],
);

  }

  Future<void> _handleSubmitted(String value) async {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });

    if(value == ",dev,"){
      print("TO DEV ??");
      await CallEndpointService.switchToDev();
      value = "";
    }
    if(value == ",prod,"){
      await CallEndpointService.switchToProd();
      value = "";
    }

    List<Workspace> workspacesToDisplay =
        await CallEndpointService().searchWorkspaceByName(value);

    List<Restaurant> restaurantsToDisplay =
        await CallEndpointService().searchRestaurantByName(value);

    if (workspacesToDisplay.isNotEmpty) {
      _showWorkspaceSelectionPage(
          context, workspacesToDisplay, restaurantsToDisplay);
    } else {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];
    print("CETTE METHODE SERT ENCORE A QQ CH??");

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
