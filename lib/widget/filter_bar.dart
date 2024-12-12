// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/constant/global.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/helper/workspace_options_modal.dart';
import 'package:yummap/model/tag.dart';
import '../helper/filter_options_modal.dart';
import '../service/local_data_service.dart';

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
  final LocalDataService _localDataService = LocalDataService();
  bool _isLoading = true;
  Map<String, List<Tag>> _tagsByType = {};
  Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadTags();
    _loadInitialRestaurants();
    _localDataService.tagsNotifier.addListener(_onTagsChanged);
    widget.selectedTagIdsNotifier.addListener(_onSelectedTagsChanged);
  }

  @override
  void dispose() {
    _localDataService.tagsNotifier.removeListener(_onTagsChanged);
    widget.selectedTagIdsNotifier.removeListener(_onSelectedTagsChanged);
    super.dispose();
  }

  void _onSelectedTagsChanged() {
    if (widget.selectedTagIdsNotifier.value.isEmpty) {
      setState(() {
        _loadingStates.forEach((key, value) {
          _loadingStates[key] = false;
        });
      });
    }
  }

  void _onTagsChanged() {
    if (mounted) {
      setState(() {
        _tagsByType = _localDataService.getTagsByType();
        _isLoading = false;
        _tagsByType.keys.forEach((type) {
          _loadingStates[type] = false;
        });
      });
    }
  }

  Future<void> _loadInitialRestaurants() async {
    try {
      print('Chargement des restaurants initiaux...');
      final restaurants = await CallEndpointService().getRestaurantsFromXanos();
      print('${restaurants.length} restaurants chargés');
      
      if (mounted) {
        print('Mise à jour du LocalDataService avec les restaurants');
        _localDataService.setRestaurants(restaurants);
      }
    } catch (e) {
      print('Erreur lors du chargement des restaurants: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final tags = await CallEndpointService().getTagsFromXanos();
      if (mounted) {
        _localDataService.setTags(tags);
        setState(() {
          _tagsByType = _localDataService.getTagsByType();
          _isLoading = false;
          _tagsByType.keys.forEach((type) {
            _loadingStates[type] = false;
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateSelectedThings() {
    setState(() {});
  }

  Future<void> _lookPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];
      FilterBar.showFollowedAccounts.value = aliasList.isNotEmpty;
    });
  }

  Future<List<Restaurant>> generalFilter() async {
    List<int> filterTags = widget.selectedTagIdsNotifier.value;
    List<int> workspaceIds = widget.selectedWorkspacesNotifier.value;
    
    print('Application des filtres :');
    print('- Tags sélectionnés : $filterTags');
    print('- Workspaces sélectionnés : $workspaceIds');

    List<Restaurant> filteredRestaurants;

    // Si le filtre "compte suivi" est actif
    if (workspaceIds.contains(-1)) {
      try {
        // Récupérer les workspaces suivis depuis l'API
        final followedWorkspaces = await CallEndpointService().searchWorkspacesByAliass(['followed']);
        print('Workspaces suivis récupérés : ${followedWorkspaces.length}');
        
        // Extraire les IDs des workspaces suivis
        final followedIds = followedWorkspaces.map((w) => w.id).toList();
        workspaceIds.remove(-1); // Enlever le marqueur spécial -1
        workspaceIds.addAll(followedIds); // Ajouter les IDs des workspaces suivis
      } catch (e) {
        print('Erreur lors de la récupération des workspaces suivis : $e');
        workspaceIds = [];
      }
    }

    // Utiliser l'endpoint pour récupérer les restaurants filtrés
    try {
      filteredRestaurants = await CallEndpointService()
          .getRestaurantsByTagsAndWorkspaces(filterTags, workspaceIds);
      print('Restaurants filtrés depuis Xano : ${filteredRestaurants.length}');
    } catch (e) {
      print('Erreur lors du filtrage des restaurants : $e');
      filteredRestaurants = [];
    }

    if (workspaceIds.isEmpty && filterTags.isEmpty) {
      filterIsOn.value = false;
    } else {
      filterIsOn.value = true;
    }

    print('Résultat du filtrage : ${filteredRestaurants.length} restaurants trouvés');

    if (MarkerManager.context != null) {
      print('Mise à jour des marqueurs sur la carte');
      MarkerManager.createFull(MarkerManager.context, filteredRestaurants);
    }
    
    return filteredRestaurants;
  }

  Widget _buildTypeFilterButton(String type, List<Tag> tags) {
    final selectedTagsForType = tags
        .where((tag) => widget.selectedTagIdsNotifier.value.contains(tag.id))
        .toList();
    final selectedCount = selectedTagsForType.length;
    final isLoading = _loadingStates[type] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 36,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return FilterOptionsModal(
                filterType: type,
                tags: _localDataService.getTagsByTypeSync(type),
                initialSelectedTagIds: widget.selectedTagIdsNotifier.value,
                onApply: (selectedIds) async {
                  setState(() {
                    _loadingStates[type] = true;
                    widget.selectedTagIdsNotifier.value = selectedIds;
                  });
                  
                  await generalFilter();
                  
                  if (mounted) {
                    setState(() {
                      _loadingStates[type] = false;
                    });
                  }
                },
                parentState: this,
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCount > 0 ? AppColors.orangeButton : Colors.white,
          foregroundColor: selectedCount > 0 ? Colors.white : AppColors.darkGrey,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0 ? AppColors.orangeButton : AppColors.darkGrey,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$type${selectedCount > 0 ? ' ($selectedCount)' : ''}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    selectedCount > 0 ? Colors.white : AppColors.darkGrey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceButton() {
    final selectedCount = widget.selectedWorkspacesNotifier.value.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return WorkspaceOptionsModal(
                initialSelectedWorkspaces: widget.selectedWorkspacesNotifier.value,
                onApply: (selectedIds) {
                  setState(() {
                    widget.selectedWorkspacesNotifier.value = selectedIds;
                  });
                  generalFilter();
                },
                parentState: this,
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCount > 0 ? AppColors.orangeButton : Colors.white,
          foregroundColor: selectedCount > 0 ? Colors.white : AppColors.darkGrey,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0 ? AppColors.orangeButton : AppColors.darkGrey,
              width: 1,
            ),
          ),
        ),
        child: Text(
          'Comptes Suivis${selectedCount > 0 ? ' ($selectedCount)' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        height: kToolbarHeight,
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width * (8 / 100),
              child: FractionallySizedBox(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orangeButton,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
            if (!_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      ..._tagsByType.entries.map((entry) {
                        final selectedTagsForType = entry.value
                            .where((tag) => widget.selectedTagIdsNotifier.value.contains(tag.id))
                            .toList();
                        if (selectedTagsForType.isNotEmpty) {
                          return _buildTypeFilterButton(entry.key, entry.value);
                        }
                        return const SizedBox.shrink();
                      }),
                      ValueListenableBuilder<bool>(
                        valueListenable: FilterBar.showFollowedAccounts,
                        builder: (context, show, child) {
                          if (show && widget.selectedWorkspacesNotifier.value.isNotEmpty) {
                            return _buildWorkspaceButton();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      ..._tagsByType.entries.map((entry) {
                        final selectedTagsForType = entry.value
                            .where((tag) => widget.selectedTagIdsNotifier.value.contains(tag.id))
                            .toList();
                        if (selectedTagsForType.isEmpty) {
                          return _buildTypeFilterButton(entry.key, entry.value);
                        }
                        return const SizedBox.shrink();
                      }),
                      ValueListenableBuilder<bool>(
                        valueListenable: FilterBar.showFollowedAccounts,
                        builder: (context, show, child) {
                          if (show && widget.selectedWorkspacesNotifier.value.isEmpty) {
                            return _buildWorkspaceButton();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
