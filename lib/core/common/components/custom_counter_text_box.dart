import 'package:flutter/material.dart';

import 'custom_labeled_text_box.dart';

class CustomCounterTextBox extends StatelessWidget {
  CustomCounterTextBox({
    super.key,
    required this.label,
    required this.controller,
    required this.quantity,
    this.enabled = true,
    this.onChanged,
  }) {
   controller.text = quantity.value.toString();
  }

  final String label;
  final TextEditingController controller;
  final ValueNotifier<int> quantity;
  final bool enabled;
  final void Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: quantity,
      builder: (BuildContext context, int value, Widget? child) {
        return CustomLabeledTextBox(
          label: label,
          controller: controller,
          enabled: enabled,
          isNumeric: true,
          suffixWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: enabled
                    ? () {
                  quantity.value++;
                  controller.text = quantity.value.toString();
                  if (onChanged != null) {
                    onChanged!(quantity.value);
                  }
                }
                    : null,
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  size: 18.0,
                ),
              ),
              InkWell(
                onTap: enabled
                    ? () {
                  quantity.value--;
                  controller.text = quantity.value.toString();
                  if (onChanged != null) {
                    onChanged!(quantity.value);
                  }
                }
                    : null,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
