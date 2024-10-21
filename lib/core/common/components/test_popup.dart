import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'custom_icon_button.dart';

class TestPopup extends StatefulWidget {
  final String? tooltip;
  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;
  final String? initialItemSelected;
  final IconData icon;
  final bool isIconOutlined;
  final bool isPopupContainerOutlined;
  //final double? height;
  //final double? width;
  final bool trackSelection;

  const TestPopup({
    super.key,
    this.tooltip,
    required this.items,
    required this.onItemSelected,
    this.initialItemSelected,
    required this.icon,
    this.isIconOutlined = false,
    this.isPopupContainerOutlined = true,
    // this.height,
    // this.width,
    this.trackSelection = true,
  });

  @override
  _TestPopupState createState() => _TestPopupState();
}

class _TestPopupState extends State<TestPopup> {
  late ValueNotifier<String?> _selectedItemNotifier;

  @override
  void initState() {
    super.initState();
    // Initialize the ValueNotifier with the initial selected item
    _selectedItemNotifier = ValueNotifier<String?>(widget.initialItemSelected);
  }

  @override
  void dispose() {
    _selectedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      tooltip: widget.tooltip,
      icon: widget.icon,
      isOutlined: widget.isIconOutlined,
      onTap: () {
        _showCustomMenu(context);
      },
    );
  }

  void _showCustomMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Create a custom popup menu with a border around the entire menu
    final popupMenu = Material(
      color: Colors.transparent,
      child: Container(
        width: 200.0,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            final text = item['text'] as String;
            final icon = item['icon'] as IconData?;
            return PopupMenuItem<String>(
              value: text,
              enabled: true,
              child: ValueListenableBuilder<String?>(
                valueListenable: _selectedItemNotifier,
                builder: (context, selectedItem, child) {
                  return _CustomMenuItem(
                    text: text,
                    icon: icon,
                    isSelected: widget.trackSelection && selectedItem == text,
                    onItemSelected: (selected) {
                      if (widget.trackSelection) {
                        _selectedItemNotifier.value = selected;
                      }
                      widget.onItemSelected(selected);
                      context.pop();
                    },
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );

    // Show the custom popup menu
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.left,
              top: position.top,
              right: position.right,
              //width: 200.0,
              child: popupMenu,
            ),
          ],
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null && widget.trackSelection) {
        widget.onItemSelected(selectedItem);
      }
    });
  }
}

class _CustomMenuItem extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final Function(String) onItemSelected;

  const _CustomMenuItem({
    required this.text,
    this.icon,
    required this.isSelected,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onItemSelected(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).dividerColor.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isSelected ? Colors.blue : Theme.of(context).iconTheme.color,
                size: 16.0,
              ),
            const SizedBox(width: 8.0),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 150.0,
              ),
              child: Text(
                text,
                style: isSelected
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                )
                    : Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import 'custom_icon_button.dart';
//
// class TestPopup extends StatefulWidget {
//   final String? tooltip;
//   final List<Map<String, dynamic>> items;
//   final Function(String) onItemSelected;
//   final String? initialItemSelected;
//   final IconData icon;
//   final bool isIconOutlined;
//   final bool isPopupContainerOutlined;
//   final double? height;
//   final double? width;
//   final bool trackSelection; // New flag for tracking selection
//
//   const TestPopup({
//     super.key,
//     this.tooltip,
//     required this.items,
//     required this.onItemSelected,
//     this.initialItemSelected,
//     required this.icon,
//     this.isIconOutlined = false,
//     this.isPopupContainerOutlined = true,
//     this.height,
//     this.width,
//     this.trackSelection = true, // Default to true
//   });
//
//   @override
//   _TestPopupState createState() => _TestPopupState();
// }
//
// class _TestPopupState extends State<TestPopup> {
//   late ValueNotifier<String?> _selectedItemNotifier;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the ValueNotifier with the initial selected item
//     _selectedItemNotifier = ValueNotifier<String?>(widget.initialItemSelected);
//   }
//
//   @override
//   void dispose() {
//     _selectedItemNotifier.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomIconButton(
//       tooltip: widget.tooltip,
//       icon: widget.icon,
//       isOutlined: widget.isIconOutlined,
//       onTap: () {
//         _showCustomMenu(context);
//       },
//     );
//   }
//
//   // void _showCustomMenu(BuildContext context) {
//   //   final RenderBox button = context.findRenderObject() as RenderBox;
//   //   final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
//   //
//   //   final RelativeRect position = RelativeRect.fromRect(
//   //     Rect.fromPoints(
//   //       button.localToGlobal(Offset.zero, ancestor: overlay),
//   //       button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
//   //     ),
//   //     Offset.zero & overlay.size,
//   //   );
//   //
//   //   showDialog(
//   //     context: context,
//   //     barrierColor: Colors.transparent,
//   //     builder: (BuildContext context) {
//   //       return Stack(
//   //         children: [
//   //           Positioned(
//   //             left: position.left,
//   //             top: position.top,
//   //             child: Material(
//   //               color: Colors.transparent,
//   //               child: Container(
//   //                 decoration: BoxDecoration(
//   //                   color: Theme.of(context).canvasColor,
//   //                   borderRadius: BorderRadius.circular(10.0),
//   //                   border: Border.all(
//   //                     color: Colors.blue, // Outline color
//   //                     width: 2.0,         // Outline width
//   //                   ),
//   //                   boxShadow: [
//   //                     BoxShadow(
//   //                       color: Colors.black26,
//   //                       blurRadius: 10.0,
//   //                       offset: Offset(0, 4),
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 child: LayoutBuilder(
//   //                   builder: (context, constraints) {
//   //                     return Column(
//   //                       mainAxisSize: MainAxisSize.min,
//   //                       children: widget.items.map((item) {
//   //                         final text = item['text'] as String;
//   //                         final icon = item['icon'] as IconData?;
//   //                         return Container(
//   //                           padding: EdgeInsets.symmetric(horizontal: 8.0),
//   //                           child: PopupMenuItem<String>(
//   //                             value: text,
//   //                             enabled: true,
//   //                             child: Row(
//   //                               mainAxisSize: MainAxisSize.min,
//   //                               children: [
//   //                                 if (icon != null)
//   //                                   Icon(icon),
//   //                                 SizedBox(width: 8.0),
//   //                                 Flexible(
//   //                                   child: Text(
//   //                                     text,
//   //                                     overflow: TextOverflow.ellipsis,
//   //                                   ),
//   //                                 ),
//   //                               ],
//   //                             ),
//   //                           ),
//   //                         );
//   //                       }).toList(),
//   //                     );
//   //                   },
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   ).then((selectedItem) {
//   //     if (selectedItem != null && widget.trackSelection) {
//   //       widget.onItemSelected(selectedItem);
//   //     }
//   //   });
//   // }
//
//
//   void _showCustomMenu(BuildContext context) {
//     final RenderBox button = context.findRenderObject() as RenderBox;
//     final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
//
//     final RelativeRect position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(Offset.zero, ancestor: overlay),
//         button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
//       ),
//       Offset.zero & overlay.size,
//     );
//
//     // Create a custom popup menu with a border around the entire menu
//     final popupMenu = Material(
//       color: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(
//             color: Theme.of(context).dividerColor, // Outline color
//             width: 1.0,        // Outline width
//           ),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 10.0,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: widget.items.map((item) {
//             final text = item['text'] as String;
//             final icon = item['icon'] as IconData?;
//             return PopupMenuItem<String>(
//               value: text,
//               enabled: true, // Ensure menu item is selectable
//               child: ValueListenableBuilder<String?>(
//                 valueListenable: _selectedItemNotifier,
//                 builder: (context, selectedItem, child) {
//                   return _CustomMenuItem(
//                     text: text,
//                     icon: icon,
//                     isSelected: widget.trackSelection && selectedItem == text,
//                     onItemSelected: (selected) {
//                       if (widget.trackSelection) {
//                         _selectedItemNotifier.value = selected;
//                       }
//                       widget.onItemSelected(selected);
//                       context.pop();
//                     },
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//
//     // Show the custom popup menu
//     showDialog(
//       context: context,
//       barrierColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Stack(
//           children: [
//             Positioned(
//               left: position.left,
//               top: position.top,
//               right: position.right,
//               child: popupMenu,
//             ),
//           ],
//         );
//       },
//     ).then((selectedItem) {
//       if (selectedItem != null && widget.trackSelection) {
//         widget.onItemSelected(selectedItem);
//       }
//     });
//   }
// }
//
// class _CustomMenuItem extends StatelessWidget {
//   final String text;
//   final IconData? icon;
//   final bool isSelected;
//   final Function(String) onItemSelected;
//
//   const _CustomMenuItem({
//     required this.text,
//     this.icon,
//     required this.isSelected,
//     required this.onItemSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Create a ValueNotifier to manage hover state
//     final ValueNotifier<bool> isHoveredNotifier = ValueNotifier<bool>(false);
//
//     return ValueListenableBuilder<bool>(
//       valueListenable: isHoveredNotifier,
//       builder: (context, isHovered, child) {
//         return MouseRegion(
//           onEnter: (_) {
//             isHoveredNotifier.value = true;
//           },
//           onExit: (_) {
//             isHoveredNotifier.value = false;
//           },
//           child: GestureDetector(
//             onTap: () {
//               onItemSelected(text);
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
//               decoration: BoxDecoration(
//                 color: isHovered || isSelected
//                     ? Theme.of(context).dividerColor.withOpacity(0.6)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Row(
//                 children: [
//                   if (icon != null)
//                     Icon(
//                       icon,
//                       color: isSelected ? Colors.blue : Theme.of(context).iconTheme.color,
//                       size: 16.0,
//                     ),
//                   const SizedBox(width: 8.0),
//                   Expanded(
//                     child: Text(
//                       text,
//                       style: isSelected
//                           ? Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: Colors.blue,
//                         fontSize: 12.0,
//                         fontWeight: FontWeight.w600,
//                       )
//                           : Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontSize: 12.0,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }