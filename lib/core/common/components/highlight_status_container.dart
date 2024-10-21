import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class StatusStyle {
  const StatusStyle({
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    required this.label,
  });

  factory StatusStyle.green({required String label}) {
    return StatusStyle(
      borderColor: AppColor.greenOutline,
      backgroundColor: AppColor.greenBackground,
      textColor: AppColor.greenText,
      label: label,
    );
  }

  factory StatusStyle.yellow({required String label}) {
    return StatusStyle(
      borderColor: AppColor.yellowOutline,
      backgroundColor: AppColor.yellowBackground,
      textColor: AppColor.yellowText,
      label: label,
    );
  }

  factory StatusStyle.blue({required String label}) {
    return StatusStyle(
      borderColor: const Color(0xFF4CB3D4),
      backgroundColor: const Color(0xFFEEF9FD),
      textColor: const Color(0xFF000000),
      label: label,
    );
  }

  factory StatusStyle.red({required String label}) {
    return StatusStyle(
      borderColor: AppColor.redOutline,
      backgroundColor: AppColor.redBackground,
      textColor: AppColor.redText,
      label: label,
    );
  }

  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final String label;
}

class HighlightStatusContainer<T> extends StatelessWidget {
  const HighlightStatusContainer({
    super.key,
    required this.statusStyle,
  });

  final StatusStyle statusStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: statusStyle.borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
        color: statusStyle.backgroundColor,
      ),
      child: Text(
        statusStyle.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusStyle.textColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
