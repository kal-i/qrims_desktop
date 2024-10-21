import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';

class SlideableContainer extends StatefulWidget {
  final Widget content; // The content to display inside the modal
  final bool isVisible; // Whether the modal is visible or not
  final Duration animationDuration; // Duration of the slide animation
  final double width; // Width of the modal container
  final VoidCallback? onClose; // Callback when the modal is closed

  const SlideableContainer({
    super.key,
    required this.content,
    required this.isVisible,
    this.animationDuration = const Duration(milliseconds: 300),
    this.width = 300, // Default width
    this.onClose, // Optional onClose callback
  });

  @override
  _SlideableContainerState createState() => _SlideableContainerState();
}

class _SlideableContainerState extends State<SlideableContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The container slides in/out based on widget.isVisible
        AnimatedPositioned(
          duration: widget.animationDuration,
          right: widget.isVisible
              ? 0
              : -widget.width - 40, // Ensure it's fully off-screen
          top: 0,
          bottom: 0,
          child: Container(
            width: widget.width,
            margin: const EdgeInsets.all(20),
            //padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkPrimary.withOpacity(0.25),
                  blurRadius: 4.0,
                  spreadRadius: 0.5,
                  offset: const Offset(0.0, 4.0),
                ),
              ],
              color: Theme.of(context)
                  .scaffoldBackgroundColor, // You can customize the color
            ),
            child: Stack(
              children: [
                widget.content, // The content inside the slideable modal
                // todo: I think I'll make this optional because there will be instances where no close button is needed
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child:
                //   InkWell(
                //     hoverColor: Theme.of(context).dividerColor,
                //     onTap: () {
                //       if (widget.onClose != null) {
                //         widget.onClose!();
                //       }
                //     },
                //     child: const Icon(
                //       HugeIcons.strokeRoundedCancel01,
                //       size: 16.0,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
