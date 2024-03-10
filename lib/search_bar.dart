import 'package:flutter/material.dart';

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
          CheckboxListTile(
            title: Text('Type de cuisine: Italien'),
            value: selectedFilters.contains('Type de cuisine: Italien'),
            onChanged: (bool? value) {
              setState(() {
                if (value != null && value) {
                  selectedFilters.add('Type de cuisine: Italien');
                } else {
                  selectedFilters.remove('Type de cuisine: Italien');
                }
              });
            },
          ),
          // Ajouter d'autres CheckboxListTile pour chaque filtre...
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