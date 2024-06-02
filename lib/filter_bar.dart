import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  _FilterBarState createState() => _FilterBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static ValueNotifier<bool> showFollowedAccounts = ValueNotifier<bool>(true);

  static void toggleFollowedAccountsFilter() {
    showFollowedAccounts.value = !showFollowedAccounts.value;
    _FilterBarState()._updateSelectedThings();
  }

  static void showAccounts() {
    showFollowedAccounts.value = true;
    _FilterBarState()._updateSelectedThings();
  }

  static void hideAccounts() {
    showFollowedAccounts.value = false;
    _FilterBarState()._updateSelectedThings();
  }
}

class _FilterBarState extends State<FilterBar> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // Ne pas respecter la marge en haut
      child: Container(
        color: Colors.white, // Couleur de fond blanc
        child: Row(
          children: [
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterOptionsModal(
                      initialSelectedTagIds: selectedTagIds,
                      onApply: (selectedIds) {
                        setState(() {
                          selectedTagIds = selectedIds;
                        });
                      },
                    );
                  },
                );
              },
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orangeButton,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
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
                      );
                    },
                  );
                },
                child: Material(
                  elevation: 2, // élévation pour donner l'effet de surélévation
                  color: Colors.white,
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
            ),
            ValueListenableBuilder<bool>(
              valueListenable: FilterBar.showFollowedAccounts,
              builder: (context, show, child) {
                return Visibility(
                  visible: aliasList.isNotEmpty && show,
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
                            );
                          },
                        );
                      },
                      child: Material(
                        elevation:
                            2, // élévation pour donner l'effet de surélévation
                        color: Colors.white,
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
