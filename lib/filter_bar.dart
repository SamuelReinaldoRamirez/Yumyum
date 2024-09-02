// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/global.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/search_bar.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace_options_modal.dart';
import 'filter_options_modal.dart';

class FilterBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;

  const FilterBar({
    Key? key,
    required this.selectedTagIdsNotifier,
    required this.selectedWorkspacesNotifier,
  }) : super(key: key);

  @override
  FilterBarState createState() => FilterBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static ValueNotifier<bool> showFollowedAccounts = ValueNotifier<bool>(true);

  static void toggleFollowedAccountsFilter() {
    showFollowedAccounts.value = !showFollowedAccounts.value;
    FilterBarState()._updateSelectedThings();
  }

  static void showAccounts() {
    showFollowedAccounts.value = true;
    FilterBarState()._updateSelectedThings();
  }

  static void hideAccounts() {
    showFollowedAccounts.value = false;
    FilterBarState()._updateSelectedThings();
  }
}

class FilterBarState extends State<FilterBar> {
  List<int> selectedTagIds = [];
  List<String> aliasList = [];
    bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _lookPref();
    widget.selectedTagIdsNotifier.addListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.addListener(_updateSelectedThings);
    showWorCircleFilterInSearchBar.value = false;
  }

  @override
  void dispose() {
    widget.selectedTagIdsNotifier.removeListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.removeListener(_updateSelectedThings);
    showWorCircleFilterInSearchBar.value = true; 
    super.dispose();
  }

  void _updateSelectedThings() {
    setState(() {});
  }

  // Fonction asynchrone pour récupérer les workspaces sauvegardés
  Future<void> _lookPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      aliasList = prefs.getStringList('workspaceAliases') ?? [];
      FilterBar.showFollowedAccounts.value = aliasList.isNotEmpty;
    });
  }

  Future<List<Restaurant>> generalFilter() async{
    List<int> filterTags = widget.selectedTagIdsNotifier.value;
    List<int> workspaceIds = widget.selectedWorkspacesNotifier.value;
    List<Restaurant> newRestoList =  await CallEndpointService().getRestaurantsByTagsAndWorkspaces(filterTags, workspaceIds);
    MarkerManager.createFull(MarkerManager.context, newRestoList);
    if(workspaceIds.isEmpty && filterTags.isEmpty){
      filterIsOn.value = false;
    }else{
      filterIsOn.value = true;
    }
    return newRestoList;
  }

  @override
  Widget build(BuildContext context) {
    return 
    //  ColorFiltered(
    //         colorFilter: _isBottomSheetOpen
    //             ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
    //             : ColorFilter.mode(Colors.transparent, BlendMode.darken),
    //         child:
            SafeArea(
      top: false, // Ne pas respecter la marge en haut
      bottom: false,
      child: Container(
        child: Row(
          children: [
            const SizedBox(width: 10),




            // Container(
            //   width: MediaQuery.of(context).size.width * (8 / 100), // 8% de l'espace horizontal
            //   child: FractionallySizedBox(
            //     alignment: Alignment.center,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: AppColors.orangeButton, // Fond orange
            //       ),
            //       padding: const EdgeInsets.all(5), // Un peu plus d'espace autour de l'icône
            //       child: const Icon(
            //         Icons.filter_list,
            //         color: Colors.white,
            //         size: 25, // Augmenter légèrement la taille de l'icône pour plus de visibilité
            //       ),
            //     ),
            //   ),
            // ),

            InkWell(
        onTap: () {
          print("REMOVE OVERLAY");
          SearchBarState().removeOverlay();
        },
        borderRadius: BorderRadius.circular(50), // Assurez-vous que l'effet d'onde soit circulaire
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

      ),






            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: _isBottomSheetOpen
                  ? null
                  : () {
                      setState(() {
                        _isBottomSheetOpen = true;
                      });

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
                      parentState: this,
                    );
                  },
                ).whenComplete(() {
                        setState(() {
                          _isBottomSheetOpen = false;
                        });
                      });
                    },
              child: Material(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Filtres',
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: FilterBar.showFollowedAccounts,
              builder: (context, show, child) {
                return Visibility(
                  visible: show,
                  child: Expanded(
                    child: GestureDetector(
                      onTap: _isBottomSheetOpen
                        ? null
                        : () {
                            setState(() {
                              _isBottomSheetOpen = true;
                            });

                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return WorkspaceOptionsModal(
                              initialSelectedWorkspaces:
                                  widget.selectedWorkspacesNotifier.value,
                              onApply: (selectedIds) {
                                setState(() {
                                  widget.selectedWorkspacesNotifier.value =
                                      selectedIds;
                                });
                              },
                              parentState: this,
                            );
                          },
                        ).whenComplete(() {
                        setState(() {
                          _isBottomSheetOpen = false;
                        });
                      });
                    },
                      child: Material(
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Comptes Suivis',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    // ),
    );
  }
}

