// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:yummap/caching.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/global.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/tag.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/translate_utils.dart';
import 'package:yummap/widgetUtils.dart';
import 'package:yummap/workspace.dart';
import 'package:yummap/workspace_selection_page.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:shared_preferences/shared_preferences.dart';
//pour faire des choses en secouant le téléphone
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Restaurant> restaurantList;
  final Function(String) onSearchChanged;
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier; 
  final List<Tag> tagList;


  const SearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.restaurantList,
    required this.selectedTagIdsNotifier,
    required this.selectedWorkspacesNotifier, required this.tagList,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  // pour faire des choses en secouant le telephone
  static const double shakeThresholdGravity = 2.7;
  static const int shakeSlopTimeMs = 500;
  int lastShakeTimestamp = 0;
  bool _shakeDetectionEnabled = false; // Variable pour activer/désactiver la détection

// StreamSubscription pour l'accéléromètre
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  
@override
  void dispose() {
    // Ne pas oublier de retirer l'écouteur lors de la destruction du widget
    filterIsOn.removeListener(() {});
    orangeCross.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Activer la détection de secousses au départ
    _enableShakeDetection();

    // Écouter les changements de filterIsOn
    filterIsOn.addListener(() {
      setState(() {});
    });
    orangeCross.addListener(() {
      setState(() {});
    });
  }

  // @override
  // void initState() {
  //   super.initState();

  //   //pour faire des choses en secouant le téléphone
  //   accelerometerEvents.listen((AccelerometerEvent event) {
  //     final now = DateTime.now().millisecondsSinceEpoch;

  //     if ((now - lastShakeTimestamp) > shakeSlopTimeMs) {
  //       final gX = event.x / 9.81;
  //       final gY = event.y / 9.81;
  //       final gZ = event.z / 9.81;

  //       final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

  //       if (gForce > shakeThresholdGravity) {
  //         lastShakeTimestamp = now;
  //         _randomRestaurant();
  //       }
  //     }
  //   });

  //   // Écouter les changements de filterIsOn
  //   filterIsOn.addListener(() {
  //     setState(() {});
  //   });
  // }

    // Activer la détection de secousses
  void _enableShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_shakeDetectionEnabled) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      if ((now - lastShakeTimestamp) > shakeSlopTimeMs) {
        final gX = event.x / 9.81;
        final gY = event.y / 9.81;
        final gZ = event.z / 9.81;
        final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          lastShakeTimestamp = now;
          _randomRestaurant();
        }
      }
    });
  }

  // Désactiver la détection de secousses
  void _disableShakeDetection() {
    _accelerometerSubscription.pause();
  }

  // Fonction pour activer ou désactiver la détection de secousses
  void _enableOrDisableShake() {
    setState(() async {
      _shakeDetectionEnabled = !_shakeDetectionEnabled;
      if (_shakeDetectionEnabled) {
        _accelerometerSubscription.resume();
      } else {
        _accelerometerSubscription.pause();
      }
       // Affiche l'alerte avec le bon message
      String shakeModeStatus = _shakeDetectionEnabled ? 'Shake mode ON' : 'Shake mode OFF';

      CustomTranslate translator = CustomTranslate();

      // Traduire le message
      String translatedMessage = await translator.translate(
        shakeModeStatus,
        "en",
        context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode,
      );

      String translateTitle = await translator.translate(
        'Information',
        "en",
        context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translateTitle),
            content: Text(translatedMessage),
            actions: <Widget>[
              TextButton(
                child: Text('OK'.tr()),
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                },
              ),
            ],
          );
        },
      );

    });
  }
  

//pour faire des choses en secouant le telephone
  void _randomRestaurant() {
    Random random = Random();
    int randomIndex = random.nextInt(widget.restaurantList.length);
    FocusScope.of(context).requestFocus(FocusNode());
    BottomSheetHelper.showBottomSheet(
        MarkerManager.context, widget.restaurantList[randomIndex]);
  }


@override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min, // Réduit l'espace vertical
    children: [
      AppBar(
        titleSpacing: 0.0, // Supprime l'espacement autour du titre
        toolbarHeight: 40.0,
        leading: boutonFiltreOrangeSearchBar(
          context, 
          (List<int> selectedIds) {
            setState(() {
              widget.selectedTagIdsNotifier.value = selectedIds;
            });
          },
        ), // Réduit la hauteur de la barre d'applications
        title: _buildSearchBar(),
        actions: [
         infobulle(context),
        ]
      ),
      // Condition pour afficher le Divider et la FilterBar ensemble
      ValueListenableBuilder<bool>(
        valueListenable: isFilterOpen,
        builder: (context, filterIsOpen, child) {
          if (!filterIsOpen) {
            return Container(); // N'affiche rien si hasSubscription est vrai
          } else {
            return 

ValueListenableBuilder<bool>(
        valueListenable: hasSubscription,
        builder: (context, subscriptions, child) {
          if (!subscriptions) {
            return Container(); // N'affiche rien si hasSubscription est vrai
          } else {
            return
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: FilterBar(
                    selectedTagIdsNotifier: selectedTagIdsNotifier,
                    selectedWorkspacesNotifier: selectedWorkspacesNotifier,
                  ),
                ),
              ],
            );
          }
        }
);


          }
        },
      ),
    ],
  );
}


Widget _buildSearchBar() {
  return TextField(
    controller: _searchController,
    onSubmitted: (value) {
      _handleSubmitted(value, _searchController);
    },
    onChanged: (value) {
      // Cette fonction sera appelée chaque fois que le texte change
      widget.onSearchChanged(value);
      if(value!=""){
        // filterIsOn.value = true;
        orangeCross.value = true;
        print("VALUE TRUE");
      }else{
        // filterIsOn.value = false;
        orangeCross.value = false;
        print("VALUE FALSE");
      }
    },
    style: AppTextStyles.paragraphDarkStyle,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Ajustement pour un meilleur alignement vertical
      // hintText: 'Rechercher dans Yummap',
      hintText: 'research.placeholder'.tr(),

      hintStyle: AppTextStyles.hintTextDarkStyle,
      border: InputBorder.none,
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.greenishGrey,
        size: 24.0, // Taille ajustée pour correspondre à celle du suffixIcon
      ),
      suffixIcon: IconButton(
        icon: Container(
          decoration: (filterIsOn.value || orangeCross.value)
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orangeButton,
                )
              : null,
          child: Icon(
            Icons.clear,
            color: (filterIsOn.value || orangeCross.value) ? Colors.white : AppColors.greenishGrey,
            size: 24.0, // Taille ajustée pour correspondre à celle du prefixIcon
          ),
          padding: EdgeInsets.all(8.0), // Ajustement du padding pour correspondre à l'icône
        ),
        onPressed: () async {
          setState(() {
            widget.selectedWorkspacesNotifier.value = [];
            widget.selectedTagIdsNotifier.value = [];
          });
          _clearSearch(context);
          MarkerManager.resetMarkers();
          filterIsOn.value = false;
          orangeCross.value = false;
        },
      ),
    ),
  );
}

  Future<void> _handleSubmitted(String value, TextEditingController _searchController) async {
    MixpanelService.instance.track('TextSearch', properties: {
      'searchText': value,
    });

    if(value == ",dev,"){
      print("TO DEV ??");
      await CallEndpointService.switchToDev();
      value = "";
      orangeCross.value = false;
      return;
    }
    if(value == ",prod,"){
      await CallEndpointService.switchToProd();
      value = "";
      orangeCross.value = false;
      return;
    }
    if(value == "##"){
      _randomRestaurant();
      return;
    }
    if(value == "#"){
      _enableOrDisableShake();
      _searchController.clear();
      orangeCross.value = false;
      return;
    }
    // if(value == "#lang"){
    //   // filtersLocalizedFinishedLoading.value = false;
    //   await showLocaleSelectionDialog(context);
    //   print('FIN DE ALERT');
    //   //appeler la mise à jour de filtres et cuisine tags AAABBB
    //   await createOrUpdateGLOBALLocalizedJsonFile(widget.tagList, context);
    //   // filtersLocalizedFinishedLoading.value = true;
    //   print("GLOBAL FILTERS CHANGED !!!!!!!!!!!!!!!!!!!!!!!");
    //   _searchController.clear();
    //   orangeCross.value = false;
    //   return;
    // }
    if (value == "#lang") {
      // Attendre le résultat de showLocaleSelectionDialog
      bool dialogResult = await showLocaleSelectionDialog(context);
      _searchController.clear();
      orangeCross.value = false;

      print('FIN DE ALERT');
      
      // Si l'utilisateur a cliqué sur "OK", exécuter la mise à jour
      if (dialogResult) {
        await createOrUpdateGLOBALLocalizedJsonFile(widget.tagList, context);
        print("GLOBAL FILTERS CHANGED !!!!!!!!!!!!!!!!!!!!!!!");
      } else {
        print("Action annulée par l'utilisateur.");
      }
      return;
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
          SnackBar(
            content: Text("no result found".tr()),
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
              child: Text("OK".tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleWorkspaceSelection(Workspace workspace) async { //sert à rien
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];

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
