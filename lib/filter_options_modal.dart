import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/tag.dart';

import 'restaurant.dart';

class FilterOptionsModal extends StatefulWidget {
  const FilterOptionsModal({Key? key}) : super(key: key);

  @override
  _FilterOptionsModalState createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  List<int> selectedTagIds = [];
  List<Tag> tagList = [];

  @override
  void initState() {
    super.initState();
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    List<Tag> tags = await CallEndpointService.getTagsFromXanos();
    setState(() {
      tagList = tags;
    });
  }

  Widget _buildApplyButton(BuildContext context) {
    MixpanelService.instance.track('FilterTagSearch', properties: {
      'filter_ids': selectedTagIds,
    });
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () async {
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
            MarkerManager.createFull(context, newRestaurants);
            Navigator.of(context).pop(); // Ferme le BottomSheet
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              Colors.grey.shade50), // Couleur de fond bleue
        ),
        child: const Text('Appliquer'),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        'Filtres',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      title: Text(tag.tag),
                      value: selectedTagIds.contains(tag.id),
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
      ],
    );
  }
}
