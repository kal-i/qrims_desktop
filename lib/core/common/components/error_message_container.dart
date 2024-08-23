import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class ErrorMessageContainer extends StatelessWidget {
  const ErrorMessageContainer({
    super.key,
    required this.errorMessage,
  });

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(5.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.error,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
        color: AppColor.pastelRed,
      ),
      child: Text(
        errorMessage,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(
          color: AppColor.darkPrimary,
        ),
      ),
    );
  }
}
