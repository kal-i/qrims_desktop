import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class CustomMessageBox extends StatelessWidget {
  const CustomMessageBox.info({
    super.key,
    required this.message,
    this.titleText = 'INFO',
    this.icon = Icons.info_outline,
    this.boxColor = AppColor.lightBlue,
    this.sideColor = AppColor.lightBlueOutline,
    this.textColor = AppColor.lightBlueText,
  });

  const CustomMessageBox.error({
    super.key,
    required this.message,
    this.titleText = 'ERROR',
    this.icon = Icons.error_outline,
    this.boxColor = AppColor.lightRed,
    this.sideColor = AppColor.lightRedOutline,
    this.textColor = AppColor.lightRedText,
  });

  const CustomMessageBox.warning({
    super.key,
    required this.message,
    this.titleText = 'WARNING',
    this.icon = Icons.warning_amber_outlined,
    this.boxColor = AppColor.lightYellow,
    this.sideColor = AppColor.lightYellowOutline,
    this.textColor = AppColor.lightYellowText,
  });

  const CustomMessageBox.success({
    super.key,
    required this.message,
    this.titleText = 'SUCCESS',
    this.icon = Icons.check_circle_outline,
    this.boxColor = AppColor.lightGreen,
    this.sideColor = AppColor.lightGreenOutline,
    this.textColor = AppColor.lightGreenText,
  });

  final String message;
  final String titleText;
  final Color boxColor;
  final Color sideColor;
  final IconData icon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: sideColor,
            width: 5.0,
          ),
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: boxColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.info,
                  color: textColor,
                  size: 25.0,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.0,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
