import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../config/sizing/sizing_config.dart';
import '../../../config/themes/app_color.dart';
import 'custom_filled_button.dart';

class CustomLoadingFilledButton extends StatelessWidget {
  const CustomLoadingFilledButton({
    super.key,
    this.onTap,
    required this.text,
    required this.isLoadingNotifier,
    required this.height,
  });

  final VoidCallback? onTap;
  final String text;
  final ValueNotifier<bool> isLoadingNotifier;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, child) {
        return CustomFilledButton(
          height: height,
          onTap: isLoading ? null : onTap,
          text: text,
          prefixWidget: isLoading
              ? SpinKitFadingCircle(
                  color: AppColor.lightPrimary,
                  size: SizingConfig.heightMultiplier * 2.0,
                )
              : null,
        );
      },
    );
  }
}
