import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:yummap/helper/favorite_manager.dart';
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
import 'package:flutter_map/flutter_map.dart';

class FilterBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;
  final ValueNotifier<bool> ratingFilterNotifier;
  final ValueNotifier<bool> filterFavoritesNotifier;
  final ValueNotifier<bool> filterIsOn;
  final Function(RangeValues, int, List<String>) onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedTagIdsNotifier,
    required this.selectedWorkspacesNotifier,
    required this.ratingFilterNotifier,
    required this.filterFavoritesNotifier,
    required this.filterIsOn,
    required this.onFilterChanged,
  });

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
  late ValueNotifier<bool> _isRatingFilterActive;
  final ValueNotifier<double> minRatingThreshold = ValueNotifier<double>(1.0);
  final ValueNotifier<double> maxRatingThreshold = ValueNotifier<double>(5.0);
  final ValueNotifier<bool> _isPeopleFilterActive = ValueNotifier<bool>(false);
  int? selectedPeopleCount;
  final ScrollController _scrollController = ScrollController();
  List<lat2.LatLng> locations = [];
  bool showMarkerInfo = true;
  RangeValues selectedPriceRange = const RangeValues(0, 100);
  int selectedRating = 0;
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _isRatingFilterActive = widget.ratingFilterNotifier;
    widget.filterFavoritesNotifier.addListener(() {
      generalFilter();
    });
    widget.filterFavoritesNotifier.addListener(() {
      generalFilter();
    });
    _loadInitialState();
  }

  @override
  void dispose() {
    widget.filterFavoritesNotifier.removeListener(() {
      generalFilter();
    });
    widget.filterFavoritesNotifier.removeListener(() {
      generalFilter();
    });
    _scrollController.dispose();
    _localDataService.tagsNotifier.removeListener(_onTagsChanged);
    widget.selectedTagIdsNotifier.removeListener(_onSelectedTagsChanged);
    _isRatingFilterActive.dispose();
    minRatingThreshold.dispose();
    maxRatingThreshold.dispose();
    _isPeopleFilterActive.dispose();
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

  Future<void> generalFilter() async {
    setState(() {});
    List<Restaurant> filteredRestaurants;

    // Step 1: Filter by tags and workspaces
    List<int> selectedTags = widget.selectedTagIdsNotifier.value;
    List<int> selectedWorkspaces = widget.selectedWorkspacesNotifier.value;
    filteredRestaurants = await CallEndpointService()
        .getRestaurantsByTagsAndWorkspaces(selectedTags, selectedWorkspaces);

    // Step 2: Apply favorites filter if active
    if (widget.filterFavoritesNotifier.value) {
      // Utiliser la liste actuelle depuis MarkerManager
      filteredRestaurants =
          await filterFavoriteRestaurants(filteredRestaurants);
    }

    // Step 3: Apply rating filter if active
    if (_isRatingFilterActive.value) {
      filteredRestaurants = filteredRestaurants.where((restaurant) {
        double rating = restaurant.ratings.toDouble();
        return rating >= minRatingThreshold.value &&
            rating <= maxRatingThreshold.value;
      }).toList();
    }

    if (filteredRestaurants.isNotEmpty) {
      List<Marker> newMarkers =
          await MapHelper.createMarkersFromRestaurants(filteredRestaurants);
      MarkerManager.swapMarkersList(newMarkers);
    } else {
      MarkerManager.clearMarkers();
    }
  }

  // Fonction pour filtrer les restaurants favoris
  Future<List<Restaurant>> filterFavoriteRestaurants(
      List<Restaurant> restaurants) async {
    List<Restaurant> favoriteRestaurants = [];
    for (Restaurant restaurant in restaurants) {
      if (await FavoriteManager.isFavorite(restaurant)) {
        favoriteRestaurants.add(restaurant);
      }
    }
    return favoriteRestaurants;
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'ambiance':
        return Icons.brunch_dining;

      case 'cuisine':
        return Icons.restaurant_menu;

      case 'restrictions':
        return Icons.no_meals;

      case 'formules':
        return Icons.food_bank;

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
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                              Expanded(
                                child: FilterOptionsModal(
                                  filterType: type,
                                  tags:
                                      _localDataService.getTagsByTypeSync(type),
                                  initialSelectedTagIds:
                                      widget.selectedTagIdsNotifier.value,
                                  onApply: (selectedIds) async {
                                    _scrollToStart();
                                    setState(() {
                                      _loadingStates[type] = true;
                                      widget.selectedTagIdsNotifier.value =
                                          selectedIds;
                                    });

                                    await generalFilter();

                                    if (mounted) {
                                      setState(() {
                                        _loadingStates[type] = false;
                                      });
                                    }
                                  },
                                  parentState: this,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCount > 0 ? AppColors.secondaryColor : Colors.white,
          foregroundColor:
              selectedCount > 0 ? Colors.white : AppColors.textColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0
                  ? AppColors.secondaryColor
                  : AppColors.textColor,
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
              color: selectedCount > 0 ? Colors.white : AppColors.textColor,
            ),
            const SizedBox(width: 4),
            Text(
              '$type${selectedCount > 0 ? ' ($selectedCount)' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selectedCount > 0 ? Colors.white : AppColors.textColor,
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
                    selectedCount > 0 ? Colors.white : AppColors.textColor,
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

                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.4,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Comptes Suivis',
                                    style: AppTextStyles.titleDarkStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ValueListenableBuilder<List<Workspace>>(
                                  valueListenable: _localDataService
                                      .followedWorkspacesNotifier,
                                  builder:
                                      (context, followedWorkspaces, child) {
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
                                          controller: scrollController,
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
                                                activeColor:
                                                    AppColors.secondaryColor,
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
                                  backgroundColor: AppColors.secondaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: Size(double.infinity, 0),
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
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCount > 0 ? AppColors.secondaryColor : Colors.white,
          foregroundColor:
              selectedCount > 0 ? Colors.white : AppColors.textColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCount > 0
                  ? AppColors.secondaryColor
                  : AppColors.textColor,
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
                  Icon(
                    Icons.people,
                    size: 18,
                    color:
                        selectedCount > 0 ? Colors.white : AppColors.textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Comptes Suivis${selectedCount > 0 ? ' ($selectedCount)' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedCount > 0
                          ? Colors.white
                          : AppColors.textColor,
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
          if (!isFilterOn && _isRatingFilterActive.value) {
            _isRatingFilterActive.value = false;
          }

          return ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: RatingFilterModal(
                      initialMinRating: minRatingThreshold.value,
                      initialMaxRating: maxRatingThreshold.value,
                      onApply: (min, max) async {
                        setState(() {
                          minRatingThreshold.value = min;
                          maxRatingThreshold.value = max;
                          _isRatingFilterActive.value =
                              (min > 1.0 || max < 5.0);
                        });
                        if (_isRatingFilterActive.value) {
                          filterIsOn.value = true;
                          _scrollToStart();
                        }
                        await generalFilter();
                      },
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRatingFilterActive.value
                  ? AppColors.secondaryColor
                  : Colors.white,
              foregroundColor: _isRatingFilterActive.value
                  ? Colors.white
                  : AppColors.textColor,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _isRatingFilterActive.value
                      ? AppColors.secondaryColor
                      : AppColors.textColor,
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
                  color: _isRatingFilterActive.value
                      ? Colors.white
                      : AppColors.textColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _isRatingFilterActive.value
                      ? '${minRatingThreshold.value.toStringAsFixed(1)}-${maxRatingThreshold.value.toStringAsFixed(1)}'
                      : 'Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isRatingFilterActive.value
                        ? Colors.white
                        : AppColors.textColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesFilterButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.filterFavoritesNotifier,
      builder: (context, isFavoriteFilter, child) {
        return FilterChip(
          selected: isFavoriteFilter,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFavoriteFilter
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                size: 20,
                color: isFavoriteFilter ? Colors.white : AppColors.textColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Favoris',
                style: TextStyle(
                  color: isFavoriteFilter ? Colors.white : AppColors.textColor,
                ),
              ),
            ],
          ),
          onSelected: (bool selected) async {
            // Mise à jour simple du notifier, comme pour le rating
            widget.filterFavoritesNotifier.value = selected;
            if (selected) {
              widget.filterIsOn.value = true;
            }
            // Appel de generalFilter qui appliquera tous les filtres
            await generalFilter();
          },
          selectedColor: AppColors.secondaryColor,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isFavoriteFilter
                  ? AppColors.secondaryColor
                  : AppColors.textColor,
              width: 1,
            ),
          ),
        );
      },
    );
  }

  void _scrollToStart() {
    if (_scrollController.hasClients) {
      double targetPosition = _scrollController.position.minScrollExtent;

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool get isRatingFilterActive => _isRatingFilterActive.value;

  set isRatingFilterActive(bool value) {
    _isRatingFilterActive.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
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
                    color: isFilterOn
                        ? AppColors.secondaryColor
                        : AppColors.textColor,
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
                        if (_isRatingFilterActive.value)
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
                        if (widget.filterFavoritesNotifier.value)
                          _buildFavoritesFilterButton(),
                        ..._tagsByType.entries.map((entry) {
                          final selectedTagsForType = entry.value
                              .where((tag) => widget
                                  .selectedTagIdsNotifier.value
                                  .contains(tag.id))
                              .toList();
                          if (selectedTagsForType.isNotEmpty) {
                            return _buildTypeFilterButton(
                                entry.key, entry.value);
                          }
                          return const SizedBox.shrink();
                        }),
                        if (!_isRatingFilterActive.value)
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
                        if (!widget.filterFavoritesNotifier.value)
                          _buildFavoritesFilterButton(),
                        ..._tagsByType.entries.map((entry) {
                          final selectedTagsForType = entry.value
                              .where((tag) => widget
                                  .selectedTagIdsNotifier.value
                                  .contains(tag.id))
                              .toList();
                          if (selectedTagsForType.isEmpty) {
                            return _buildTypeFilterButton(
                                entry.key, entry.value);
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
      ),
    );
  }
}
