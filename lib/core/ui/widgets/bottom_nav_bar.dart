// lib/core/ui/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

typedef TabSelectedCallback = void Function(int index);

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final TabSelectedCallback? onTabSelected;

  const BottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onTabSelected,
  });

  static const _items = <_NavItem>[
    _NavItem(label: 'Home', icon: Icons.home_rounded),
    _NavItem(label: 'Search', icon: Icons.search_rounded),
    _NavItem(label: 'Scan', icon: Icons.qr_code_scanner_rounded),
    _NavItem(label: 'Categories', icon: Icons.grid_view_rounded),
    _NavItem(label: 'Upload', icon: Icons.cloud_upload_rounded),
    _NavItem(label: 'Smart Read', icon: Icons.document_scanner_rounded),
  ];

  void _handleTap(int index) {
    onTabSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final selectedColor = Colors.teal.shade600;
    final inactiveColor = Colors.teal.shade300;

    return Material(
      elevation: 10,
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: bottomPadding > 0 ? bottomPadding : 10,
            left: 6,
            right: 6,
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleTap(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: selected
                            ? BoxDecoration(
                          color: Colors.teal.shade100,
                          shape: BoxShape.circle,
                        )
                            : null,
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: selected ? selectedColor : inactiveColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? selectedColor : inactiveColor,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}
