// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
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
    return ElevatedButton(
      onPressed: () async {
        // Appliquer les filtres et fermer le modal
        List<Restaurant> newRestaurants =
            await CallEndpointService.getRestaurantsByTags(
                selectedTagIds); // Passer les identifiants de tags sélectionnés
        MarkerManager.createFull(context, newRestaurants);
        Navigator.of(context).pop();
        // Appeler la fonction de rappel pour nettoyer les marqueurs
      },
      child: const Text('Appliquer'),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
