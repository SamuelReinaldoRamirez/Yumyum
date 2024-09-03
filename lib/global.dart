  import 'package:flutter/material.dart';

final ValueNotifier<bool> filterIsOn = ValueNotifier<bool>(false);
ValueNotifier<List<int>> selectedTagIdsNotifier =
      ValueNotifier<List<int>>([]);
  ValueNotifier<List<int>> selectedWorkspacesNotifier =
      ValueNotifier<List<int>>([]);
