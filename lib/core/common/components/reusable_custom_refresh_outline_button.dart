import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'custom_icon_button.dart';

class ReusableCustomRefreshOutlineButton extends StatelessWidget {
  const ReusableCustomRefreshOutlineButton({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onTap: onTap,
      tooltip: 'Refresh',
      icon: FluentIcons.arrow_clockwise_dashes_20_regular,
      isOutlined: true,
    );
  }
}
