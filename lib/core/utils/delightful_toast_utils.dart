import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

/// Note: this causes an err if the context is not already in the widget tree
/// my solution: delay the navigation when showing a msg
class DelightfulToastUtils {
  static void showDelightfulToast({
    required BuildContext context,
    IconData? icon,
    required String title,
    required String subtitle,
  }) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          DelightToastBar(
            snackbarDuration: const Duration(milliseconds: 2950),
            autoDismiss: true,
            builder: (context) {
              return ToastCard(
                leading: Icon(
                  icon,
                  size: 20.0,
                ),
                title: Text(
                  title,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400
                  ),
                ),
              );
            },
          ).show(context);
        }
      });
    }
  }
}
