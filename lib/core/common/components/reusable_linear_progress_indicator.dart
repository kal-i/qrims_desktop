import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class ReusableLinearProgressIndicator extends StatelessWidget {
  const ReusableLinearProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Theme.of(context).dividerColor,
      color: AppColor.accent,
    );
  }
}
