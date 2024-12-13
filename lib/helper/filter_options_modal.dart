import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.filterType ?? 'Filtres',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.tags.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Aucun filtre disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.tags.length,
                    itemBuilder: (context, index) {
                      final tag = widget.tags[index];
                      final isSelected = selectedTagIds.contains(tag.id);

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(tag.tag),
                        trailing: Checkbox(
                          value: isSelected,
                          activeColor: AppColors.orangeButton,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedTagIds.add(tag.id);
                              } else {
                                selectedTagIds.remove(tag.id);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTagIds.remove(tag.id);
                            } else {
                              selectedTagIds.add(tag.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeButton,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              widget.onApply(selectedTagIds.toList());
              Navigator.pop(context);
            },
            child: const Text(
              'Appliquer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
