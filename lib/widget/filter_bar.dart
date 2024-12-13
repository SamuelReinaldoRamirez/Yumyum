import 'package:flutter/material.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/constant/global.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/tag.dart';
import 'package:yummap/model/workspace.dart';
import '../helper/filter_options_modal.dart';
import '../service/local_data_service.dart';
import '../helper/rating_filter_modal.dart';

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
  final Map<String, bool> _loadingStates = {};
  bool _isLoadingWorkspaces = false;
  List<int> _tempSelectedWorkspaces = [];
  double _minRating = 1.0;
  double _maxRating = 5.0;
  bool _isRatingFilterActive = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        for (var type in _tagsByType.keys) {
          _loadingStates[type] = false;
        }
      });
    }
  }

  Future<void> _loadInitialState() async {
    await _localDataService.loadFollowedWorkspaces();
    _loadTags();
    _loadInitialRestaurants();
    _localDataService.tagsNotifier.addListener(_onTagsChanged);
    widget.selectedTagIdsNotifier.addListener(_onSelectedTagsChanged);
  }

  Future<void> _loadInitialRestaurants() async {
    try {
      final restaurants = await CallEndpointService().getRestaurantsFromXanos();

      if (mounted) {
        _localDataService.setRestaurants(restaurants);
      }
    } catch (e) {}
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
          for (var type in _tagsByType.keys) {
            _loadingStates[type] = false;
          }
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

  // Méthode publique pour réinitialiser les filtres
  void resetFilters() {
    setState(() {
      // Reset rating filter
      _isRatingFilterActive = false;
      _minRating = 1.0;
      _maxRating = 5.0;

      // Reset other filters
      widget.selectedTagIdsNotifier.value = [];
      widget.selectedWorkspacesNotifier.value = [];

      // Reset loading states
      for (var type in _tagsByType.keys) {
        _loadingStates[type] = false;
      }
      _isLoadingWorkspaces = false;

      // Reset filter state
      filterIsOn.value = false;

      // Force UI update
      setState(() {});

      // Update filters
      generalFilter();
    });
  }

  Future<List<Restaurant>> generalFilter() async {
    List<int> filterTags = widget.selectedTagIdsNotifier.value;
    List<int> workspaceIds = widget.selectedWorkspacesNotifier.value;

    if (_isRatingFilterActive) {}

    List<Restaurant> filteredRestaurants;

    // Si le filtre "compte suivi" est actif
    if (workspaceIds.contains(-1)) {
      // Utiliser la liste locale des workspaces suivis
      final followedWorkspaces = _localDataService.getFollowedWorkspaces();

      // Extraire les IDs des workspaces suivis
      final followedIds = followedWorkspaces.map((w) => w.id).toList();
      workspaceIds.remove(-1);
      workspaceIds.addAll(followedIds);
    }

    // Utiliser l'endpoint pour récupérer les restaurants filtrés
    try {
      filteredRestaurants = await CallEndpointService()
          .getRestaurantsByTagsAndWorkspaces(filterTags, workspaceIds);

      // Appliquer le filtre de note si actif
      if (_isRatingFilterActive) {
        filteredRestaurants = filteredRestaurants.where((restaurant) {
          // Vérifier si le restaurant a une note valide
          if (restaurant.ratings > 0) {
            final bool isInRange = restaurant.ratings >= _minRating &&
                restaurant.ratings <= _maxRating;
            return isInRange;
          }
          return false; // Exclure les restaurants sans note
        }).toList();
      }
    } catch (e) {
      filteredRestaurants = [];
    }

    // Mettre à jour filterIsOn en fonction de tous les filtres actifs
    if (workspaceIds.isEmpty && filterTags.isEmpty && !_isRatingFilterActive) {
      filterIsOn.value = false;
    } else {
      filterIsOn.value = true;
    }

    MarkerManager.createFull(MarkerManager.context, filteredRestaurants);

    return filteredRestaurants;
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      // Ambiance
      case 'ambiance':
        return Icons.brunch_dining;

      // Cuisine
      case 'cuisine':
        return Icons.restaurant_menu;

      // Restrictions
      case 'restrictions':
        return Icons.no_meals;

      // Formules
      case 'formules':
        return Icons.food_bank;

      // Plat
      case 'plat':
        return Icons.cookie;

      default:
        return Icons.label_outline;
    }
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
        onPressed: isLoading
            ? null
            : () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterOptionsModal(
                      filterType: type,
                      tags: _localDataService.getTagsByTypeSync(type),
                      initialSelectedTagIds:
                          widget.selectedTagIdsNotifier.value,
                      onApply: (selectedIds) async {
                        _scrollToStart();
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
          backgroundColor:
              selectedCount > 0 ? AppColors.orangeButton : Colors.white,
          foregroundColor:
              selectedCount > 0 ? Colors.white : AppColors.darkGrey,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0
                  ? AppColors.orangeButton
                  : AppColors.darkGrey,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForType(type),
              size: 18,
            ),
            const SizedBox(width: 4),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: _isLoadingWorkspaces
            ? null
            : () {
                _tempSelectedWorkspaces =
                    List<int>.from(widget.selectedWorkspacesNotifier.value);

                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Comptes Suivis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ValueListenableBuilder<List<Workspace>>(
                              valueListenable:
                                  _localDataService.followedWorkspacesNotifier,
                              builder: (context, followedWorkspaces, child) {
                                if (followedWorkspaces.isEmpty) {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(16),
                                    child: const Text(
                                      'Aucun compte suivi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: followedWorkspaces.length,
                                      itemBuilder: (context, index) {
                                        final workspace =
                                            followedWorkspaces[index];
                                        final isSelected =
                                            _tempSelectedWorkspaces
                                                .contains(workspace.id);

                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          title: Text(workspace.name),
                                          trailing: Checkbox(
                                            value: isSelected,
                                            activeColor: AppColors.orangeButton,
                                            onChanged: (bool? value) {
                                              setModalState(() {
                                                if (value ?? false) {
                                                  _tempSelectedWorkspaces
                                                      .add(workspace.id);
                                                } else {
                                                  _tempSelectedWorkspaces
                                                      .remove(workspace.id);
                                                }
                                              });
                                            },
                                          ),
                                          onTap: () {
                                            setModalState(() {
                                              if (_tempSelectedWorkspaces
                                                  .contains(workspace.id)) {
                                                _tempSelectedWorkspaces
                                                    .remove(workspace.id);
                                              } else {
                                                _tempSelectedWorkspaces
                                                    .add(workspace.id);
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeButton,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              _scrollToStart();
                              setState(() {
                                _isLoadingWorkspaces = true;
                              });

                              try {
                                widget.selectedWorkspacesNotifier.value =
                                    _tempSelectedWorkspaces;
                                await generalFilter();
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingWorkspaces = false;
                                  });
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'Appliquer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCount > 0 ? AppColors.orangeButton : Colors.white,
          foregroundColor:
              selectedCount > 0 ? Colors.white : AppColors.darkGrey,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0
                  ? AppColors.orangeButton
                  : AppColors.darkGrey,
              width: 1,
            ),
          ),
        ),
        child: _isLoadingWorkspaces
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Comptes Suivis${selectedCount > 0 ? ' ($selectedCount)' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRatingFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ValueListenableBuilder<bool>(
        valueListenable: filterIsOn,
        builder: (context, isFilterOn, child) {
          // Si filterIsOn est false, on force _isRatingFilterActive à false aussi
          if (!isFilterOn && _isRatingFilterActive) {
            _isRatingFilterActive = false;
          }

          return ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return RatingFilterModal(
                    initialMinRating: _minRating,
                    initialMaxRating: _maxRating,
                    onApply: (min, max) async {
                      setState(() {
                        _minRating = min;
                        _maxRating = max;
                        _isRatingFilterActive = (min > 1.0 || max < 5.0);
                      });
                      if (_isRatingFilterActive) {
                        filterIsOn.value = true;
                        _scrollToStart();
                      }
                      await generalFilter();
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isRatingFilterActive ? AppColors.orangeButton : Colors.white,
              foregroundColor:
                  _isRatingFilterActive ? Colors.white : AppColors.darkGrey,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _isRatingFilterActive
                      ? AppColors.orangeButton
                      : AppColors.darkGrey,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color:
                      _isRatingFilterActive ? Colors.white : AppColors.darkGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isRatingFilterActive
                      ? '${_minRating.toStringAsFixed(1)}-${_maxRating.toStringAsFixed(1)}'
                      : 'Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isRatingFilterActive
                        ? Colors.white
                        : AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    bool hasLoadingState = _loadingStates.values.any((isLoading) => isLoading) || _isLoadingWorkspaces;
    return widget.selectedTagIdsNotifier.value.isNotEmpty ||
        widget.selectedWorkspacesNotifier.value.isNotEmpty ||
        _isRatingFilterActive ||
        hasLoadingState;
  }

  void _scrollToStart() {
    if (_scrollController.hasClients) {
      // Calculer la position du premier filtre actif
      double targetPosition = _scrollController.position.minScrollExtent;
      
      // Défiler complètement à gauche
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            const SizedBox(width: 10),
            ValueListenableBuilder<bool>(
              valueListenable: filterIsOn,
              builder: (context, isFilterOn, child) {
                return Icon(
                  Icons.filter_list,
                  color:
                      isFilterOn ? AppColors.orangeButton : AppColors.darkGrey,
                );
              },
            ),
            if (!_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      // Boutons actifs en premier
                      if (_isRatingFilterActive) 
                        _buildRatingFilterButton(),
                      if (widget.selectedWorkspacesNotifier.value.isNotEmpty)
                        ValueListenableBuilder<bool>(
                          valueListenable: FilterBar.showFollowedAccounts,
                          builder: (context, show, child) {
                            if (show) {
                              return _buildWorkspaceButton();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      // Boutons de type avec des tags sélectionnés (filtres actifs)
                      ..._tagsByType.entries.map((entry) {
                        final selectedTagsForType = entry.value
                            .where((tag) => widget.selectedTagIdsNotifier.value
                                .contains(tag.id))
                            .toList();
                        if (selectedTagsForType.isNotEmpty) {
                          return _buildTypeFilterButton(entry.key, entry.value);
                        }
                        return const SizedBox.shrink();
                      }),
                      // Boutons inactifs ensuite
                      if (!_isRatingFilterActive) 
                        _buildRatingFilterButton(),
                      if (widget.selectedWorkspacesNotifier.value.isEmpty)
                        ValueListenableBuilder<bool>(
                          valueListenable: FilterBar.showFollowedAccounts,
                          builder: (context, show, child) {
                            if (show) {
                              return _buildWorkspaceButton();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      // Boutons de type sans tags sélectionnés
                      ..._tagsByType.entries.map((entry) {
                        final selectedTagsForType = entry.value
                            .where((tag) => widget.selectedTagIdsNotifier.value
                                .contains(tag.id))
                            .toList();
                        if (selectedTagsForType.isEmpty) {
                          return _buildTypeFilterButton(entry.key, entry.value);
                        }
                        return const SizedBox.shrink();
                      }),
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
