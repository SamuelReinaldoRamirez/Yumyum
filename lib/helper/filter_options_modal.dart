// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../service/local_data_service.dart';
import 'package:yummap/model/tag.dart';
import 'package:yummap/widget/filter_bar.dart';
import 'package:yummap/constant/theme.dart';

class FilterOptionsModal extends StatefulWidget {
  final String? filterType;
  final List<Tag> tags;
  final List<int> initialSelectedTagIds;
  final Function(List<int>) onApply;
  final FilterBarState parentState;

  const FilterOptionsModal({
    Key? key,
    this.filterType,
    required this.tags,
    required this.initialSelectedTagIds,
    required this.onApply,
    required this.parentState,
  }) : super(key: key);

  @override
  State<FilterOptionsModal> createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  Set<int> selectedTagIds = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedTagIds = Set.from(widget.initialSelectedTagIds);
  }

  List<Widget> _buildTagList() {
    return widget.tags.map((tag) {
      return CheckboxListTile(
        title: Text(tag.tag),
        value: selectedTagIds.contains(tag.id),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              selectedTagIds.add(tag.id);
            } else {
              selectedTagIds.remove(tag.id);
            }
          });
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.filterType ?? 'Filtres',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onApply(selectedTagIds.toList());
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.orangeButton,
                ),
                child: const Text('Appliquer'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: _buildTagList(),
            ),
          ),
        ],
      ),
    );
  }
}
