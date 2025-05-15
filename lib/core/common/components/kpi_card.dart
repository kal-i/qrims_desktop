import 'package:flutter/material.dart';

import 'base_container.dart';

class KPICard extends StatelessWidget {
  const KPICard({
    super.key,
    required this.icon,
    required this.title,
    required this.data,
    this.description,
    this.bgColor,
    this.iconBackgroundColor,
    this.outlineColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String data;
  final String? description;
  final Color? bgColor;
  final Color? iconBackgroundColor;
  final Color? outlineColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            data,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                  color: foregroundColor,
                ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
