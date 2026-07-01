import 'package:flutter/material.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

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
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  
  bool _isOpen = false;
  String _searchText = '';
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _hideOverlay(); // Prevent memory leaks!
    super.dispose();
  }

  // Helper to format the display text
  String _getLabel(T? value) {
    if (value == null) return widget.hintText;
    return widget.itemToString != null ? widget.itemToString!(value) : value.toString();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
      _searchText = '';
      _searchController.clear();
    });
  }

  void _showOverlay() {
    final renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible layer to dismiss the dropdown when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideOverlay,
            ),
          ),
          
          // The actual dropdown menu
          Positioned(
            width: size.width, // 🔥 Matches your button's exact width!
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 4.0), // Floats just below the button
              child: Material(
                elevation: 6.0,
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280), // Prevents overflow!
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE2E5E8)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      // 🔍 Search Bar Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search,
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6), // Light gray search background
                          ),
                          onChanged: (val) {
                            _searchText = val;
                            _overlayEntry?.markNeedsBuild(); // Rebuilds the overlay state
                          },
                        ),
                      ),
                      
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E5E8)),
                      
                      // 📋 Options List
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            final filteredItems = widget.items.where((item) {
                              final label = _getLabel(item).toLowerCase();
                              return label.contains(_searchText.toLowerCase());
                            }).toList();

                            if (filteredItems.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  AppLocalizations.of(context)!.noOptionsFound,
                                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true, // Crucial for clean height mapping
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = item == widget.value;

                                return InkWell(
                                  onTap: () {
                                    widget.onChanged(item);
                                    _hideOverlay();
                                  },
                                  child: Container(
                                    color: isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getLabel(item),
                                            style: TextStyle(
                                              color: isSelected ? Colors.blue.shade700 : const Color(0xFF111111),
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check, size: 18, color: Colors.blue.shade700)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _key,
        onTap: _toggleDropdown,
        child: Container(
          width: 160, // Kept your exact requested width 📏
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E5E8),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: _isOpen ? Colors.blue : const Color(0xFFC4C7CC), 
              width: 1.0
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getLabel(widget.value),
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF111111),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
