import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).chipTheme.selectedColor,
      labelStyle: isSelected
          ? Theme.of(context).chipTheme.secondaryLabelStyle
          : Theme.of(context).chipTheme.labelStyle,
    );
  }
}
