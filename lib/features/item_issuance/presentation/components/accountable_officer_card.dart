import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/reusable_rich_text.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';

class AccountableOfficerCard extends StatelessWidget {
  final Map<String, dynamic> officer;
  final bool isDragging;
  final VoidCallback? onRemove;
  final VoidCallback? onAddItem;
  final void Function(int itemIndex)? onRemoveItem;

  const AccountableOfficerCard({
    super.key,
    required this.officer,
    this.isDragging = false,
    this.onRemove,
    this.onAddItem,
    this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final entity = officer['entity'] as String?;
    final officerInfo = officer['officer'] as Map<String, dynamic>;
    final items = (officer['items'] as List).cast<Map<String, dynamic>>();

    return Card(
      color: isDragging ? Colors.grey[300] : Theme.of(context).cardColor,
      elevation: isDragging ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officerInfo['name'] ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        officerInfo['position'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        officerInfo['office'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entity != null && entity.isNotEmpty)
                        Text(
                          entity,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Column(
                        spacing: 3.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i]['shareable_item_information']
                                ['base_item_id'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          Text(
                            items[i]['product_stock']['product_name']
                                    ['product_name']
                                .toString()
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          ReusableRichText(
                            title: 'Description',
                            value: items[i]['product_stock']
                                        ['product_description']
                                    ['product_description'] ??
                                '',
                          ),
                          if (items[i]['shareable_item_information']
                                  ['specification'] !=
                              null)
                            ReusableRichText(
                              title: 'Specifications',
                              value: items[i]['shareable_item_information']
                                  ['specification'],
                            ),
                          if (items[i]['manufacturer_brand']?['manufacturer']
                                  ['manufacturer_name'] !=
                              null)
                            ReusableRichText(
                              title: 'Manufacturer',
                              value: items[i]['manufacturer_brand']
                                  ['manufacturer']['manufacturer_name'],
                            ),
                          if (items[i]['manufacturer_brand']?['brand']
                                  ['brand_name'] !=
                              null)
                            ReusableRichText(
                              title: 'Brand',
                              value: items[i]['manufacturer_brand']['brand']
                                  ['brand_name'],
                            ),
                          if (items[i]['model']?['model_name'] != null)
                            ReusableRichText(
                              title: 'Model',
                              value: items[i]['model']['model_name'],
                            ),
                          if (items[i]['serial_no'] != null)
                            ReusableRichText(
                              title: 'SN',
                              value: items[i]['serial_no'],
                            ),
                          ReusableRichText(
                            title: 'Unit',
                            value: items[i]['shareable_item_information']
                                ['unit'],
                          ),
                          ReusableRichText(
                            title: 'Quantity',
                            value: items[i]['shareable_item_information']
                                    ['quantity']
                                .toString(),
                          ),
                          ReusableRichText(
                            title: 'Unit Cost',
                            value: formatCurrency(items[i]
                                ['shareable_item_information']['unit_cost']),
                          ),
                          if (items[i]['shareable_item_information']
                                  ['fund_cluster'] !=
                              null)
                            ReusableRichText(
                              title: 'FC',
                              value: FundCluster.values
                                  .firstWhere((e) =>
                                      e.toString().split('.').last ==
                                      items[i]['shareable_item_information']
                                          ['fund_cluster'])
                                  .toReadableString(),
                            ),
                          ReusableRichText(
                            title: 'Date Acquired',
                            value: documentDateFormatter(DateTime.parse(items[i]
                                    ['shareable_item_information']
                                ['acquired_date'])),
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
