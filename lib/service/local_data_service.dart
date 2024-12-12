import 'package:flutter/foundation.dart';
import '../model/tag.dart';
import '../model/restaurant.dart';

class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  final ValueNotifier<List<Tag>> _tagsNotifier = ValueNotifier<List<Tag>>([]);
  final ValueNotifier<List<Restaurant>> _restaurantsNotifier = ValueNotifier<List<Restaurant>>([]);
  
  ValueNotifier<List<Tag>> get tagsNotifier => _tagsNotifier;
  ValueNotifier<List<Restaurant>> get restaurantsNotifier => _restaurantsNotifier;

  final Map<String, List<Tag>> _tagsByType = {};

  void setTags(List<Tag> tags) {
    _tagsNotifier.value = tags;
    _updateTagsByType(tags);
  }

  void setRestaurants(List<Restaurant> restaurants) {
    print('Stockage de ${restaurants.length} restaurants');
    _restaurantsNotifier.value = restaurants;
  }

  void _updateTagsByType(List<Tag> tags) {
    _tagsByType.clear();
    for (var tag in tags) {
      if (tag.type != null && tag.type.isNotEmpty) {
        if (!_tagsByType.containsKey(tag.type)) {
          _tagsByType[tag.type] = [];
        }
        _tagsByType[tag.type]!.add(tag);
      }
    }
    
    _tagsByType.forEach((type, tagList) {
      tagList.sort((a, b) => a.tag.compareTo(b.tag));
    });
  }

  Map<String, List<Tag>> getTagsByType() {
    if (_tagsByType.isEmpty && _tagsNotifier.value.isNotEmpty) {
      _updateTagsByType(_tagsNotifier.value);
    }
    return Map.unmodifiable(_tagsByType);
  }

  List<Tag> getTagsByTypeSync(String type) {
    return _tagsByType[type] ?? [];
  }

  List<Restaurant> filterRestaurantsSync(List<int> tagIds, List<int> workspaceIds) {
    print('Filtrage - Tags demandés: $tagIds');
    print('Filtrage - Workspaces demandés: $workspaceIds');
    print('Nombre total de restaurants: ${_restaurantsNotifier.value.length}');

    if (tagIds.isEmpty && workspaceIds.isEmpty) {
      return List.from(_restaurantsNotifier.value);
    }

    return _restaurantsNotifier.value.where((restaurant) {
      // Vérifier les tags du restaurant
      bool matchesTags = tagIds.isEmpty || 
          restaurant.tagStr.any((restaurantTagId) => tagIds.contains(restaurantTagId));
      
      // Vérifier le workspace
      bool matchesWorkspaces = workspaceIds.isEmpty || 
          workspaceIds.contains(restaurant.id);

      print('Restaurant ${restaurant.name}:');
      print('  - Tags du restaurant: ${restaurant.tagStr}');
      print('  - Tags recherchés: $tagIds');
      print('  - Match tags: $matchesTags');
      print('  - Match workspace: $matchesWorkspaces');
      
      return matchesTags && matchesWorkspaces;
    }).toList();
  }

  // Récupérer la liste complète des restaurants
  List<Restaurant> getRestaurants() {
    return List.from(_restaurantsNotifier.value);
  }
}
