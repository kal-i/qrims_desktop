import 'package:flutter/material.dart';

import '../../../../core/common/components/base_container.dart';

class ChartContainer extends StatelessWidget {
  const ChartContainer({
    super.key,
    required this.title,
    required this.description,
    this.child,
    this.action,
  });

  final String title;
  final String description;
  final Widget? child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      height: 320.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (child != null)
            Expanded(
              child: child!,
            ),
        ],
      ),
    );
  }
}
