import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AccountableOfficerCard extends StatelessWidget {
  final Map<String, dynamic> officer;
  final bool isDragging;
  final VoidCallback? onRemove;
  final VoidCallback? onAddItem;
  final void Function(int itemIndex)? onRemoveItem; // <-- add this

  const AccountableOfficerCard({
    super.key,
    required this.officer,
    this.isDragging = false,
    this.onRemove,
    this.onAddItem,
    this.onRemoveItem, // <-- add this
  });

  @override
  Widget build(BuildContext context) {
    final officerInfo = officer['officer'] as Map<String, dynamic>;
    final items = (officer['items'] as List).cast<Map<String, dynamic>>();

    return Card(
      color: isDragging ? Colors.grey[300] : Theme.of(context).cardColor,
      elevation: isDragging ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officerInfo['name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      officerInfo['position'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      officerInfo['office'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    HugeIcons.strokeRoundedDashboardSquareRemove,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📦 Item(s) to issue:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                IconButton(
                  onPressed: onAddItem,
                  icon: const Icon(
                    HugeIcons.strokeRoundedNodeAdd,
                  ),
                ),
              ],
            ),
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i]['product_stock']['product_name']
                                    ['product_name'] ??
                                '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            items[i]['product_stock']['product_description']
                                    ['product_description'] ??
                                '',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          if (items[i]['shareable_item_information']
                                  ['specification'] !=
                              null)
                            Text(
                              'Specifications: ${items[i]['shareable_item_information']['specification']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (items[i]['manufacturer_brand']?['manufacturer']
                                  ['manufacturer_name'] !=
                              null)
                            Text(
                              'Manufacturer: ${items[i]['manufacturer_brand']['manufacturer']['manufacturer_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (items[i]['manufacturer_brand']?['brand']
                                  ['brand_name'] !=
                              null)
                            Text(
                              'Brand: ${items[i]['manufacturer_brand']['brand']['brand_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (items[i]['model']?['model_name'] != null)
                            Text(
                              'Model: ${items[i]['model']['model_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Quantity: ${items[i]['shareable_item_information']['quantity']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (onRemoveItem != null)
                      IconButton(
                        icon: const Icon(HugeIcons.strokeRoundedDelete02),
                        tooltip: 'Remove item',
                        onPressed: () => onRemoveItem!(i),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
