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
        alignment: Alignment.center,
        height: 55, // Hauteur des boutons
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.paleGreen,
                AppColors.greenishGrey, // Couleur de fin du dégradé
              // AppColors.orangeBG, // Couleur de début du dégradé
              // AppColors.orangeButton, // Couleur de fin du dégradé
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Coins arrondis
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white, // Texte en blanc
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
//             const SizedBox(width: 10),
// boutonFiltreOrangeFilterhBar(context),
// const SizedBox(width: 20),
// Expanded(
//   child: GestureDetector(
//     onTap: () {
//       showModalBottomSheet<void>(
//         context: context,
//         builder: (BuildContext context) {
//           return FilterOptionsModal(
//             initialSelectedTagIds: widget.selectedTagIdsNotifier.value,
//             onApply: (selectedIds) {
//               setState(() {
//                 widget.selectedTagIdsNotifier.value = selectedIds;
//               });
//             },
//           );
//         },
//       );
//     },
//     child: Material(
//       elevation: 6, // Augmentation de l'ombre pour un effet de profondeur
//       borderRadius: BorderRadius.circular(12), // Coins arrondis plus marqués
//       child: Container(
//         alignment: Alignment.center,
//         height: 55, // Hauteur légèrement augmentée
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppColors.orangeBG, // Couleur de début du dégradé
//               AppColors.orangeButton, // Couleur de fin du dégradé
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12), // Coins arrondis
//         ),
//         child: Text(
//           'filters'.tr(),
//           style: const TextStyle(
//             color: Colors.white, // Texte blanc pour contraster
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   ),
// ),
// const SizedBox(width: 10), // Espace entre les deux boutons
// Expanded(
//   child: ValueListenableBuilder<bool>(
//     valueListenable: FilterBar.showFollowedAccounts,
//     builder: (context, show, child) {
//       return Visibility(
//         visible: show,
//         child: GestureDetector(
//           onTap: () {
//             showModalBottomSheet<void>(
//               context: context,
//               builder: (BuildContext context) {
//                 return WorkspaceOptionsModal(
//                   initialSelectedWorkspaces:
//                       widget.selectedWorkspacesNotifier.value,
//                   onApply: (selectedIds) {
//                     setState(() {
//                       widget.selectedWorkspacesNotifier.value = selectedIds;
//                     });
//                   },
//                 );
//               },
//             );
//           },
//           child: Material(
//             elevation: 6, // Augmentation de l'ombre pour un effet de profondeur
//             borderRadius: BorderRadius.circular(12), // Coins arrondis plus marqués
//             child: Container(
//               alignment: Alignment.center,
//               height: 55, // Hauteur légèrement augmentée
//               decoration: BoxDecoration(
//                 color: Colors.white, // Couleur de fond
//                 borderRadius: BorderRadius.circular(12), // Coins arrondis
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1), // Ombre légère
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3), // Ombre en bas
//                   ),
//                 ],
//                 border: Border.all(color: AppColors.darkGrey), // Bordure
//               ),
//               child: Text(
//                 "followed workspaces".tr(),
//                 style: const TextStyle(
//                   color: AppColors.darkGrey,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   ),
// ),

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


            // const SizedBox(width: 10),
            // boutonFiltreOrangeFilterhBar(context),
            // const SizedBox(
            //   width: 20,
            // ),
            // GestureDetector(
            //   onTap: () {
            //     showModalBottomSheet<void>(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return FilterOptionsModal(
            //           initialSelectedTagIds:
            //               widget.selectedTagIdsNotifier.value,
            //           onApply: (selectedIds) {
            //             setState(() {
            //               widget.selectedTagIdsNotifier.value = selectedIds;
            //             });
            //           },
            //           // parentState: this,
            //         );
            //       },
            //     );
            //   },
            //   child: Material(
            //     child: Container(
            //       alignment: Alignment.center,
            //       child: Text(
            //         'filters'.tr(),
            //         style: const TextStyle(
            //           color: AppColors.darkGrey,
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // ValueListenableBuilder<bool>(
            //   valueListenable: FilterBar.showFollowedAccounts,
            //   builder: (context, show, child) {
            //     return Visibility(
            //       visible: show,
            //       child: Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             showModalBottomSheet<void>(
            //               context: context,
            //               builder: (BuildContext context) {
            //                 return WorkspaceOptionsModal(
            //                   initialSelectedWorkspaces:
            //                       widget.selectedWorkspacesNotifier.value,
            //                   onApply: (selectedIds) {
            //                     setState(() {
            //                       widget.selectedWorkspacesNotifier.value =
            //                           selectedIds;
            //                     });
            //                   },
            //                   // parentState: this,
            //                 );
            //               },
            //             );
            //           },
            //           child: Material(
            //             child: Container(
            //               alignment: Alignment.center,
            //               child: Text(
            //                 "followed workspaces".tr(),
            //                 style: const TextStyle(
            //                   color: AppColors.darkGrey,
            //                   fontSize: 20,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
