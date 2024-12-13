import 'package:flutter/foundation.dart';
import '../model/tag.dart';
import '../model/restaurant.dart';
import '../model/workspace.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  static final ValueNotifier<List<Tag>> _tagsNotifier =
      ValueNotifier<List<Tag>>([]);
  static final ValueNotifier<List<Restaurant>> _restaurantsNotifier =
      ValueNotifier<List<Restaurant>>([]);
  static final ValueNotifier<List<Workspace>> _followedWorkspacesNotifier =
      ValueNotifier<List<Workspace>>([]);

  final Map<String, List<Tag>> _tagsByType = {};

  LocalDataService._internal() {
    loadFollowedWorkspaces(); // Charger les workspaces suivis au démarrage
  }

  factory LocalDataService() {
    return _instance;
  }

  ValueNotifier<List<Tag>> get tagsNotifier => _tagsNotifier;
  ValueNotifier<List<Restaurant>> get restaurantsNotifier =>
      _restaurantsNotifier;
  ValueNotifier<List<Workspace>> get followedWorkspacesNotifier =>
      _followedWorkspacesNotifier;

  void setTags(List<Tag> tags) {
    _tagsNotifier.value = tags;
    _updateTagsByType(tags);
  }

  void setRestaurants(List<Restaurant> restaurants) {
    _restaurantsNotifier.value = restaurants;
  }

  void _updateTagsByType(List<Tag> tags) {
    _tagsByType.clear();
    for (var tag in tags) {
      if (tag.type.isNotEmpty) {
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

  List<Restaurant> filterRestaurantsSync(
      List<int> tagIds, List<int> workspaceIds) {
    if (tagIds.isEmpty && workspaceIds.isEmpty) {
      return List.from(_restaurantsNotifier.value);
    }

    return _restaurantsNotifier.value.where((restaurant) {
      // Vérifier les tags du restaurant
      bool matchesTags = tagIds.isEmpty ||
          restaurant.tagStr
              .any((restaurantTagId) => tagIds.contains(restaurantTagId));

      // Vérifier le workspace
      bool matchesWorkspaces =
          workspaceIds.isEmpty || workspaceIds.contains(restaurant.id);

      return matchesTags && matchesWorkspaces;
    }).toList();
  }

  // Récupérer la liste complète des restaurants
  List<Restaurant> getRestaurants() {
    return List.from(_restaurantsNotifier.value);
  }

  // Ajouter un workspace à la liste des suivis
  void addFollowedWorkspace(Workspace workspace) {
    final currentWorkspaces =
        List<Workspace>.from(followedWorkspacesNotifier.value);
    if (!currentWorkspaces.any((w) => w.id == workspace.id)) {
      currentWorkspaces.add(workspace);
      followedWorkspacesNotifier.value = currentWorkspaces;
      _saveFollowedWorkspaces(currentWorkspaces);
    }
  }

  // Retirer un workspace de la liste des suivis
  void removeFollowedWorkspace(int workspaceId) {
    final currentWorkspaces =
        List<Workspace>.from(followedWorkspacesNotifier.value);
    currentWorkspaces.removeWhere((w) => w.id == workspaceId);
    followedWorkspacesNotifier.value = currentWorkspaces;
    _saveFollowedWorkspaces(currentWorkspaces);
  }

  // Sauvegarder la liste des workspaces suivis dans SharedPreferences
  Future<void> _saveFollowedWorkspaces(List<Workspace> workspaces) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workspacesJson =
          workspaces.map((w) => jsonEncode(w.toJson())).toList();
      await prefs.setStringList('followed_workspaces', workspacesJson);
    } catch (e) {}
  }

  // Charger la liste des workspaces suivis depuis SharedPreferences
  Future<void> loadFollowedWorkspaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workspacesJson = prefs.getStringList('followed_workspaces') ?? [];
      final workspaces = workspacesJson
          .map((json) => Workspace.fromJson(jsonDecode(json)))
          .toList();
      followedWorkspacesNotifier.value = workspaces;
    } catch (e) {
      followedWorkspacesNotifier.value = [];
    }
  }

  // Récupérer la liste des workspaces suivis
  List<Workspace> getFollowedWorkspaces() {
    return List.from(_followedWorkspacesNotifier.value);
  }
}
