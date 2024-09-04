// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/global.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/widgetUtils.dart';
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

  @override
  void initState() {
    super.initState();
    _lookPref();
    widget.selectedTagIdsNotifier.addListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.addListener(_updateSelectedThings);
  }

  @override
  void dispose() {
    widget.selectedTagIdsNotifier.removeListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.removeListener(_updateSelectedThings);
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

  static Future<List<Restaurant>> generalFilter() async{
    List<int> filterTags = selectedTagIdsNotifier.value;
    List<int> workspaceIds = selectedWorkspacesNotifier.value;
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
    return SafeArea(
      top: false, // Ne pas respecter la marge en haut
      bottom: false,
      child: Container(
        child: Row(
          children: [
            const SizedBox(width: 10),
            boutonFiltreOrangeFilterhBar(context),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
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
                      // parentState: this,
                    );
                  },
                );
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
                      onTap: () {
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
                              // parentState: this,
                            );
                          },
                        );
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
    );
  }
}
