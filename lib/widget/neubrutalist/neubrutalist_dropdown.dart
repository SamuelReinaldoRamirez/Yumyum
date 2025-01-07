import 'package:flutter/material.dart';

class NeubrutalistDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String label;

  NeubrutalistDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: DropdownButton<T>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item.toString()),
        )).toList(),
        onChanged: onChanged,
        underline: SizedBox(),
      ),
    );
  }
}
