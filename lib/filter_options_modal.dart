import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/tag.dart';

import 'restaurant.dart';

class FilterOptionsModal extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtres',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 16.0),
          ListView.builder(
            shrinkWrap: true,
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
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              // Appliquer les filtres et fermer le modal
              print("===================");
              print("===================");
              print("===================");
              print(selectedTagIds);
              print("===================");
              List<Restaurant> newRestaurants =
                  await CallEndpointService.getRestaurantsByTags(
                      selectedTagIds); // Passer les identifiants de tags sélectionnés
              MarkerManager.createFull(context, newRestaurants);
              Navigator.of(context).pop();
              // Appeler la fonction de rappel pour nettoyer les marqueurs
            },
            child: Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}
