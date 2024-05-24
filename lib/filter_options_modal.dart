// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/tag.dart';
import 'package:yummap/theme.dart';

import 'restaurant.dart';

class FilterOptionsModal extends StatefulWidget {
  final List<int> initialSelectedTagIds;
  final ValueChanged<List<int>> onApply;

  const FilterOptionsModal({Key? key,
  required this.initialSelectedTagIds,
    required this.onApply,
    }) : super(key: key);

  @override
  _FilterOptionsModalState createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  List<int> selectedTagIds = [];
  List<Tag> tagList = [];

  @override
  void initState() {
    super.initState();
    //possible incohérence i on a des tags qui sont supprimés en bdd apres la premiere selection et avant de retourner sur la page de selection des filtres
    selectedTagIds = List.from(widget.initialSelectedTagIds);
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    List<Tag> tags = await CallEndpointService.getTagsFromXanos();
    setState(() {
      tagList = tags;
    });
  }

  Widget _buildApplyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          widget.onApply(selectedTagIds);
          MixpanelService.instance.track('FilterTagSearch', properties: {
            'filter_ids': selectedTagIds,
          });

          List<Restaurant> newRestaurants =
              await CallEndpointService.getRestaurantsByTags(selectedTagIds);
          if (newRestaurants.isEmpty) {
            Navigator.of(context).pop(); // Ferme le BottomSheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Aucun résultat trouvé avec ces filtres"),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    // Action à effectuer lorsque l'utilisateur appuie sur le bouton OK
                  },
                ),
              ),
            );
          } else {
            //print(newRestaurants);
            MarkerManager.createFull(context, newRestaurants);
            Navigator.of(context).pop(); // Ferme le BottomSheet
          }
        },
        style: AppButtonStyles.elevatedButtonStyle,
        child: const Text('Appliquer'),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        'Filtres',
        style: AppTextStyles.titleDarkStyle,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       _buildTitle(context),
  //       Expanded(
  //         child: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListView.builder(
  //                 shrinkWrap: true,
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 itemCount: tagList.length,
  //                 itemBuilder: (context, index) {
  //                   final tag = tagList[index];
  //                   return CheckboxListTile(
  //                     title: Text(
  //                       tag.tag,
  //                       style: AppTextStyles.paragraphDarkStyle,
  //                     ),
  //                     value: selectedTagIds.contains(tag.id),
  //                     checkColor: Colors.white,
  //                     activeColor: AppColors.greenishGrey,
  //                     onChanged: (bool? value) {
  //                       setState(() {
  //                         if (value != null && value) {
  //                           selectedTagIds.add(tag.id);
  //                         } else {
  //                           selectedTagIds.remove(tag.id);
  //                         }
  //                       });
  //                     },
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       _buildApplyButton(context),
  //       const SizedBox(height: 10),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onApply(selectedTagIds);
        return true;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tagList.length,
                    itemBuilder: (context, index) {
                      final tag = tagList[index];
                      return CheckboxListTile(
                        title: Text(
                          tag.tag,
                          style: AppTextStyles.paragraphDarkStyle,
                        ),
                        value: selectedTagIds.contains(tag.id),
                        checkColor: Colors.white,
                        activeColor: AppColors.greenishGrey,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              selectedTagIds.add(tag.id);
                            } else {
                              selectedTagIds.remove(tag.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildApplyButton(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

}
