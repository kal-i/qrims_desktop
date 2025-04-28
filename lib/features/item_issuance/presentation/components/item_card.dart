import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/reusable_rich_text.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.data,
    this.isDragging = false,
    this.onRemove,
    this.onEditQuantity,
    this.isAccountability = false,
  });

  final Map<String, dynamic> data;
  final bool isDragging;
  final VoidCallback? onRemove;
  final VoidCallback? onEditQuantity;
  final bool isAccountability;

  @override
  Widget build(BuildContext context) {
    final concreteIssuanceId = data['issuance_id'];
    final issuedDate = data['issued_date'];
    final status = data['status'];
    final returnedDate = data['returned_date'];
    final lostDate = data['lost_date'];
    final baseItemId = isAccountability
        ? data['base_item_id']
        : data['shareable_item_information']['base_item_id'];
    final productName = isAccountability
        ? data['product_name']
        : data['product_stock']['product_name']['product_name'];
    final description = isAccountability
        ? data['product_description']
        : data['product_stock']['product_description']['product_description'];
    final specification = isAccountability
        ? data['specifciation']
        : data['shareable_item_information']['specification'];
    final unit = isAccountability
        ? data['unit']
        : data['shareable_item_information']['unit'];
    final quantity = isAccountability
        ? data['issued_quantity']
        : data['shareable_item_information']['quantity'];
    final unitCost = isAccountability
        ? data['unit_cost']
        : data['shareable_item_information']['unit_cost'];
    final fundCluster = isAccountability
        ? data['fund_cluster']
        : data['shareable_item_information']['fund_cluster'];
    final dateAcquired = isAccountability
        ? data['acquired_date']
        : data['shareable_item_information']['acquired_date'];
    final manufacturer = isAccountability
        ? data['manufacturer']
        : data['manufacturer_brand']?['manufacturer']['manufacturer_name'];
    final brand = isAccountability
        ? data['brand']
        : data['manufacturer_brand']?['brand']['brand_name'];
    final model =
        isAccountability ? data['model'] : data['model']?['model_name'];
    final serialNo = isAccountability ? data['serial_no'] : data['serial_no'];
    final issuedQuantity = data['issued_quantity'];

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
                    children: [
                      if (isAccountability)
                        Column(
                          children: [
                            Text(
                              concreteIssuanceId,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              'Issued Date: ${documentDateFormatter(issuedDate)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      Text(
                        baseItemId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.visible, // Important so it wraps
                        softWrap: true, // Make sure it wraps to the next line
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
                          productName.toString().toUpperCase(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        ReusableRichText(
                          title: 'Description',
                          value: description,
                        ),
                        if (specification != null)
                          ReusableRichText(
                            title: 'Specifications',
                            value: specification,
                          ),
                        if (manufacturer != null)
                          ReusableRichText(
                            title: 'Manufacturer',
                            value: manufacturer,
                          ),
                        if (brand != null)
                          ReusableRichText(
                            title: 'Brand',
                            value: brand,
                          ),
                        if (model != null)
                          ReusableRichText(
                            title: 'Model',
                            value: model,
                          ),
                        if (serialNo != null)
                          ReusableRichText(
                            title: 'SN',
                            value: serialNo,
                          ),
                        ReusableRichText(
                          title: 'Unit',
                          value: unit,
                        ),
                        ReusableRichText(
                          title: 'Available Quantity',
                          value: quantity.toString(),
                        ),
                        ReusableRichText(
                          title: 'Unit Cost',
                          value: formatCurrency(unitCost),
                        ),
                        if (fundCluster != null)
                          ReusableRichText(
                            title: 'FC',
                            value: FundCluster.values
                                .firstWhere((e) =>
                                    e.toString().split('.').last == fundCluster)
                                .toReadableString(),
                          ),
                        ReusableRichText(
                          title: 'Date Acquired',
                          value: documentDateFormatter(
                              DateTime.parse(dateAcquired)),
                        ),
                        if (issuedQuantity != null)
                          ReusableRichText(
                            title: 'Quantity to Issue',
                            value: issuedQuantity.toString(),
                          ),
                      ],
                    ),
                  ),
                  if (onEditQuantity != null)
                    IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedEdit02),
                      tooltip: 'Edit quantity',
                      onPressed: onEditQuantity,
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
