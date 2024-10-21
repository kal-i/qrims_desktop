import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';
import 'custom_form_text_field.dart';
import 'custom_labeled_text_box.dart';

class QuantityCounterField extends StatefulWidget {
  const QuantityCounterField({
    super.key,
    required this.quantity,
    required this.controller,
  });

  final ValueNotifier<int> quantity;
  final TextEditingController controller;

  @override
  State<QuantityCounterField> createState() => _QuantityCounterFieldState();
}

class _QuantityCounterFieldState extends State<QuantityCounterField> {
  @override
  void initState() {
    super.initState();
    // Initialize controller's text with the current quantity value
    widget.controller.text = widget.quantity.value.toString();

    // Listen to changes in quantity and update the controller's text accordingly
    widget.quantity.addListener(() {
      widget.controller.text = widget.quantity.value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      label: 'Quantity',
      controller: widget.controller,
      isNumeric: true,
      suffixWidget: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              widget.quantity.value++; // Increment quantity
            },
            child: const Icon(
              HugeIcons.strokeRoundedArrowUp01,
              size: 18.0,
            ),
          ),
          InkWell(
            onTap: () {
              if (widget.quantity.value > 0) {
                widget
                    .quantity.value--; // Decrement quantity but avoid negative
              }
            },
            child: const Icon(
                    HugeIcons.strokeRoundedArrowDown01,
                    size: 18.0,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.quantity.removeListener(() {}); // Clean up the listener
    super.dispose();
  }
}
