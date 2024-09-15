// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
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

  /// Méthode pour créer un bouton stylisé
// Widget buildStyledButton({
//   required BuildContext context,
//   required String label,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Material(
//       elevation: 6, // Ombre pour donner un effet de profondeur
//       borderRadius: BorderRadius.circular(12), // Coins arrondis
//       child: Container(
//         alignment: Alignment.center,
//         height: 55, // Hauteur des boutons

//         child: Text(
//           label,
//           style: const TextStyle(
//             color: AppColors.greenishGrey, // Texte en blanc
//             fontSize: 20,
//             // fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   );
// }

Widget buildStyledButton({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Material(
      elevation: 6, // Ombre pour donner un effet de profondeur
      borderRadius: BorderRadius.circular(12), // Coins arrondis
      child: Container(
        alignment: Alignment.center, // Centre le contenu
        height: 40, // Hauteur des boutons
        padding: const EdgeInsets.symmetric(horizontal: 16), // Optionnel : ajout de rembourrage horizontal
        child: Center( // Centre le texte horizontalement et verticalement
          child: Text(
            label,
            textAlign: TextAlign.center, // Centre le texte
            style: const TextStyle( // Utilise la police Poppins
              color:  Color(0xFF95A472), // Couleur du texte
              fontSize: 16,
              fontFamily: 'Poppins'
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
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
              const SizedBox(width: 20),
              Expanded(
                child: buildStyledButton(
                  context: context,
                  label: 'filters'.tr(),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return FilterOptionsModal(
                          initialSelectedTagIds: widget.selectedTagIdsNotifier.value,
                          onApply: (selectedIds) {
                            setState(() {
                              widget.selectedTagIdsNotifier.value = selectedIds;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10), // Espace entre les deux boutons
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: FilterBar.showFollowedAccounts,
                  builder: (context, show, child) {
                    return Visibility(
                      visible: show,
                      child: buildStyledButton(
                        context: context,
                        label: "followed workspaces".tr(),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return WorkspaceOptionsModal(
                                initialSelectedWorkspaces:
                                    widget.selectedWorkspacesNotifier.value,
                                onApply: (selectedIds) {
                                  setState(() {
                                    widget.selectedWorkspacesNotifier.value = selectedIds;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}
