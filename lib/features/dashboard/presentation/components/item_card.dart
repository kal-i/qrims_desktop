import 'package:flutter/material.dart';

import '../../../../core/common/components/base_container.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../data/models/item.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
  });

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      marginBottom: 3.0,
      height: 140.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            capitalizeWord(item.productName ?? 'Unknown'),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.quantity.toString(),
            softWrap: true,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
