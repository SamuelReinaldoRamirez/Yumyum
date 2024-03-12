import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/tag.dart';

class FilterOptionsModal extends StatefulWidget {
  @override
  _FilterOptionsModalState createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  List<String> selectedFilters = [];
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
                value: selectedFilters.contains(tag.tag),
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null && value) {
                      selectedFilters.add(tag.tag);
                    } else {
                      selectedFilters.remove(tag.tag);
                    }
                  });
                },
              );
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Appliquer les filtres et fermer le modal
              MarkerManager.pop();
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
