import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_filled_button.dart';

class DropdownActionButton extends StatefulWidget {
  const DropdownActionButton({
    super.key,
    required this.actionTexts,
    required this.onActionSelected,
  });

  final List<String> actionTexts;
  final void Function(String selectedAction) onActionSelected;

  @override
  State<DropdownActionButton> createState() => _DropdownActionButtonState();
}

class _DropdownActionButtonState extends State<DropdownActionButton> {
  String _selectedAction = '';

  @override
  void initState() {
    super.initState();
    if (widget.actionTexts.isNotEmpty) {
      _selectedAction = widget.actionTexts.first;
    }
  }

  void _handleActionChange(String newAction) {
    setState(() {
      _selectedAction = newAction;
    });
    widget.onActionSelected(newAction);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomFilledButton(
          height: 40.0,
          borderRadiusTopLeft: 10.0,
          borderRadiusTopRight: 0.0,
          borderRadiusBottomLeft: 10.0,
          borderRadiusBottomRight: 0.0,
          text:
              _selectedAction.isNotEmpty ? _selectedAction : 'Select an Action',
          onTap: () {
            if (_selectedAction.isNotEmpty) {
              widget.onActionSelected(_selectedAction);
            }
          },
        ),
        const SizedBox(
          width: 1.0,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Container(
              height: 40.0,
              width: 25.0,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: AppColor.accent,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedArrowDown01,
                size: 20.0,
                color: AppColor.lightPrimary,
              ),
            ),
            value: _selectedAction,
            items: widget.actionTexts.map((actionText) {
              return DropdownMenuItem(
                value: actionText,
                child: Text(
                  actionText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _handleActionChange(newValue);
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 160.0,
              padding: EdgeInsets.symmetric(vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(),
          ),
        ),
      ],
    );
  }
}
