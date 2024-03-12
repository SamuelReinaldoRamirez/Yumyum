import 'package:flutter/material.dart';
import 'package:yummap/map_helper.dart';
import 'filter_options_modal.dart';

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
            // showModalBottomSheet<void>(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return FilterOptionsModal();
            //   },
            // );
            MarkerManager.pop();
          },
        ),
      ],
    );
  }
}
