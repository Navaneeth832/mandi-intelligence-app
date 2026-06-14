import 'package:flutter/material.dart';

class FilterDropdownButton extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const FilterDropdownButton({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5E8), // Solid grey fill from image_0aa080.png
        borderRadius: BorderRadius.circular(24.0), // Rounded pill container
        border: Border.all(color: const Color(0xFFC4C7CC), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hintText,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF111111)),
          isDense: true,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}