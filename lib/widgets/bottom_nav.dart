// // lib/widgets/bottom_nav_unused.dart
// import 'package:flutter/material.dart';
//
// /// BottomNavBar with optional GlobalKeys for tutorial targeting.
// /// Backwards-compatible: if you don't supply keys, it behaves exactly as before.
// class BottomNavBar extends StatefulWidget {
//   final ValueChanged<int>? onTabSelected;
//   final int initialIndex;
//
//   // OPTIONAL keys that allow an external tutorial to target each item.
//   final GlobalKey? homeKey;
//   final GlobalKey? searchKey;
//   final GlobalKey? scanKey;
//   final GlobalKey? categoriesKey;
//   final GlobalKey? uploadKey;
//   final GlobalKey? smartReadKey;
//
//   const BottomNavBar({
//     super.key,
//     this.onTabSelected,
//     this.initialIndex = 0,
//     this.homeKey,
//     this.searchKey,
//     this.scanKey,
//     this.categoriesKey,
//     this.uploadKey,
//     this.smartReadKey,
//   });
//
//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }
//
// class _BottomNavBarState extends State<BottomNavBar> {
//   late int _selectedIndex;
//
//   // Keep the mapping here so it's easy to change icons or labels.
//   final List<_NavItem> _items = const [
//     _NavItem(label: 'Home', icon: Icons.home_rounded),
//     _NavItem(label: 'Search', icon: Icons.search_rounded),
//     _NavItem(label: 'Scan', icon: Icons.qr_code_scanner_rounded),
//     _NavItem(label: 'Categories', icon: Icons.grid_view_rounded),
//     _NavItem(label: 'Upload', icon: Icons.cloud_upload_rounded),
//     _NavItem(label: 'Smart Read', icon: Icons.document_scanner_rounded),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;
//   }
//
//   void _onTap(int index) {
//     if (_selectedIndex == index) {
//       // Already selected — still provide feedback
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('${_items[index].label} tapped (placeholder)')),
//       );
//       return;
//     }
//
//     setState(() => _selectedIndex = index);
//     widget.onTabSelected?.call(index);
//
//     // Default placeholder action:
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('${_items[index].label} tapped (placeholder)')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
//     final Color selectedColor = const Color(0xFF6B4EFF); // distinct purple-ish color (same as before)
//     final Color inactiveColor = Colors.grey.shade600;
//
//     return Material(
//       elevation: 10,
//       color: Colors.white,
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//       child: SafeArea(
//         top: false,
//         child: Container(
//           padding: EdgeInsets.only(
//             top: 8,
//             bottom: bottomPadding > 0 ? bottomPadding : 10,
//             left: 6,
//             right: 6,
//           ),
//           child: Row(
//             children: List.generate(_items.length, (index) {
//               final item = _items[index];
//               final bool selected = index == _selectedIndex;
//
//               // Pick the correct key for this index (if provided)
//               final GlobalKey? keyForIndex = _keyForIndex(index);
//
//               return Expanded(
//                 child: InkWell(
//                   // Attach the key to the InkWell so tutorial_coach_mark can find it
//                   key: keyForIndex,
//                   onTap: () => _onTap(index),
//                   borderRadius: BorderRadius.circular(12),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // icon container with circular selected background
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         width: 44,
//                         height: 44,
//                         decoration: selected
//                             ? BoxDecoration(
//                           color: selectedColor.withOpacity(0.12),
//                           shape: BoxShape.circle,
//                         )
//                             : null,
//                         alignment: Alignment.center,
//                         child: Icon(
//                           item.icon,
//                           size: 22,
//                           color: selected ? selectedColor : inactiveColor,
//                         ),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       // label
//                       Text(
//                         item.label,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: selected ? selectedColor : inactiveColor,
//                           fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
//
//   GlobalKey? _keyForIndex(int index) {
//     switch (index) {
//       case 0:
//         return widget.homeKey;
//       case 1:
//         return widget.searchKey;
//       case 2:
//         return widget.scanKey;
//       case 3:
//         return widget.categoriesKey;
//       case 4:
//         return widget.uploadKey;
//       case 5:
//         return widget.smartReadKey;
//       default:
//         return null;
//     }
//   }
// }
//
// class _NavItem {
//   final String label;
//   final IconData icon;
//   const _NavItem({required this.label, required this.icon});
// }



// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final int initialIndex;

  final GlobalKey? homeKey;
  final GlobalKey? searchKey;
  final GlobalKey? scanKey;
  final GlobalKey? categoriesKey;
  final GlobalKey? uploadKey;
  final GlobalKey? smartReadKey;

  const BottomNavBar({
    super.key,
    this.onTabSelected,
    this.initialIndex = 0,
    this.homeKey,
    this.searchKey,
    this.scanKey,
    this.categoriesKey,
    this.uploadKey,
    this.smartReadKey,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  final List<_NavItem> _items = const [
    _NavItem(label: 'Home', icon: Icons.home_rounded),
    _NavItem(label: 'Search', icon: Icons.search_rounded),
    _NavItem(label: 'Scan', icon: Icons.qr_code_scanner_rounded),
    _NavItem(label: 'Categories', icon: Icons.grid_view_rounded),
    _NavItem(label: 'Upload', icon: Icons.cloud_upload_rounded),
    _NavItem(label: 'Smart Read', icon: Icons.document_scanner_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    // 🔒 Prevent re-triggering the same tab
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // 🔥 PURE navigation callback (no UI side effects)
    widget.onTabSelected?.call(index);
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
              final selected = index == _selectedIndex;
              final keyForIndex = _keyForIndex(index);

              return Expanded(
                child: InkWell(
                  key: keyForIndex,
                  onTap: () => _onTap(index),
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
                          fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
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

  GlobalKey? _keyForIndex(int index) {
    switch (index) {
      case 0:
        return widget.homeKey;
      case 1:
        return widget.searchKey;
      case 2:
        return widget.scanKey;
      case 3:
        return widget.categoriesKey;
      case 4:
        return widget.uploadKey;
      case 5:
        return widget.smartReadKey;
      default:
        return null;
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}
