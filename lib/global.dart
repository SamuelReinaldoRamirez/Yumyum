import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> filterIsOn = ValueNotifier<bool>(false);
ValueNotifier<List<int>> selectedTagIdsNotifier = ValueNotifier<List<int>>([]);
ValueNotifier<List<int>> selectedWorkspacesNotifier = ValueNotifier<List<int>>([]);
ValueNotifier<bool> hasSubscription = ValueNotifier<bool>(false);
ValueNotifier<bool> showWorCircleFilterInSearchBar 
  = ValueNotifier<bool>(true); 

// Cette fonction initialise les variables asynchrones
Future<void> initializeGlobals() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var aliasList = prefs.getStringList('workspaceAliases') ?? [];
  hasSubscription.value = aliasList.isNotEmpty;
}