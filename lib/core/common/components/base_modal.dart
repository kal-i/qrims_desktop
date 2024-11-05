import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class BaseModal extends StatelessWidget {
  const BaseModal({
    super.key,
    this.content,
    this.footer,
    required this.headerTitle,
    this.subtitle,
    this.width,
    this.height,
  });

  final Widget? content;
  final Widget? footer;
  final String headerTitle;
  final String? subtitle;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,//Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width ?? 450.0,
          maxHeight: height ?? 500.0,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModalHeader(
              title: headerTitle,
              subtitle: subtitle,
            ),
            const SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: _ModalContent(
                child: content,
              ),
            ),
            _ModalFooter(
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => context.pop(),
              icon: Icon(
                HugeIcons.strokeRoundedCancel01,
                size: 20.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
          ),
      ],
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}

class _ModalFooter extends StatelessWidget {
  const _ModalFooter({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
