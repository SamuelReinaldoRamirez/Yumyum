import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/tag.dart';

class SearchBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearchChanged;

  const SearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              // Effacer le texte de recherche
              onSearchChanged('');
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return FilterOptionsModal();
              },
            );
          },
        ),
      ],
    );
  }
}

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
              Navigator.of(context).pop();
            },
            child: Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}
