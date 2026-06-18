import 'package:flutter/material.dart';

class FilterDropdownButton<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemToString;

  const FilterDropdownButton({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
    this.itemToString,
  });

  @override
  State<FilterDropdownButton<T>> createState() => _FilterDropdownButtonState<T>();
}

class _FilterDropdownButtonState<T> extends State<FilterDropdownButton<T>> {
  late TextEditingController _controller;

  String _getLabel(T? value) {
    if (value == null) return '';
    return widget.itemToString != null ? widget.itemToString!(value) : value.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getLabel(widget.value));
  }

  @override
  void didUpdateWidget(covariant FilterDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _getLabel(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      controller: _controller,
      width: 160,
      textStyle: const TextStyle(
        color: Color(0xFF111111),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      onSelected: widget.onChanged,
      hintText: widget.hintText,
      enableSearch: true,
      enableFilter: true,
      requestFocusOnTap: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE2E5E8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Color(0xFFC4C7CC), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Color(0xFFC4C7CC), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Color(0xFFC4C7CC), width: 1.0),
        ),
      ),
      dropdownMenuEntries: widget.items.map<DropdownMenuEntry<T>>((T item) {
        final label = widget.itemToString != null ? widget.itemToString!(item) : item.toString();
        return DropdownMenuEntry<T>(
          value: item,
          label: label,
        );
      }).toList(),
    );
  }
}
