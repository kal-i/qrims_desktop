import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AccountableOfficerCard extends StatelessWidget {
  final Map<String, dynamic> officer;
  final bool isDragging;
  final VoidCallback? onRemove;
  final VoidCallback? onAddItem;

  const AccountableOfficerCard({
    super.key,
    required this.officer,
    this.isDragging = false,
    this.onRemove,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    print('raw data received by accountable officer card: $officer');
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
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3.0,
                        children: [
                          // Text(
                          //   item['shareable_item_information']
                          //           ['base_item_id'] ??
                          //       '',
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .bodyMedium
                          //       ?.copyWith(
                          //         fontSize: 14.0,
                          //         fontWeight: FontWeight.w700,
                          //       ),
                          // ),
                          Text(
                            item['product_stock']['product_name']
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
                            item['product_stock']['product_description']
                                    ['product_description'] ??
                                '',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          if (item['shareable_item_information']
                                  ['specification'] !=
                              null)
                            Text(
                              'Specifications: ${item['shareable_item_information']['specification']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (item['manufacturer_brand']?['manufacturer']
                                  ['manufacturer_name'] !=
                              null)
                            Text(
                              'Manufacturer: ${item['manufacturer_brand']['manufacturer']['manufacturer_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (item['manufacturer_brand']?['brand']
                                  ['brand_name'] !=
                              null)
                            Text(
                              'Brand: ${item['manufacturer_brand']['brand']['brand_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (item['model']?['model_name'] != null)
                            Text(
                              'Model: ${item['model']['model_name']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Quantity: ${item['shareable_item_information']['quantity']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
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
