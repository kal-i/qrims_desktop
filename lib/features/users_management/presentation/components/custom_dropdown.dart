import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.sortingValue,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<String> sortingValue;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          icon: const Icon(
            Icons.keyboard_arrow_down_outlined,
            color: AppColor.accent,
            size: 20.0,
          ),
          items: sortingValue
              .map(
                (sortValue) => DropdownMenuItem<String>(
                  value: sortValue,
                  child: Text(
                    sortValue,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
