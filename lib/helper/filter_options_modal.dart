// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/widget/filter_bar.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/model/tag.dart';
import 'package:yummap/constants/theme.dart';

import '../model/restaurant.dart';

class FilterOptionsModal extends StatefulWidget {
  final List<int> initialSelectedTagIds;
  final ValueChanged<List<int>> onApply;
  final FilterBarState parentState;

  const FilterOptionsModal({
    Key? key,
    required this.initialSelectedTagIds,
    required this.onApply,
    required this.parentState,
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
    selectedTagIds = List.from(widget.initialSelectedTagIds);
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    List<Tag> tags = await CallEndpointService().getTagsFromXanos();
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
              await widget.parentState.generalFilter();
          if (newRestaurants.isEmpty) {
            Navigator.of(context).pop(); // Ferme le BottomSheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    "Aucun résultat trouvé avec ces filtres ou combinaison de filtres"),
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
            Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: handleBackNavigation(),
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

  bool handleBackNavigation() {
    //à ne pas supprimer : ici on définit ce qu'il se passe quand on clique en dehors du bottomsheet
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // AlertDialog(semanticLabel: "selection perdue");
    // });
    return true; // Retourne true pour permettre le pop, false pour l'empêcher
  }
}
