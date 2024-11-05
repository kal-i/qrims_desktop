import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/enums/purchase_request_status.dart';

class PurchaseRequestKPICard extends StatelessWidget {
  const PurchaseRequestKPICard({
    super.key,
    required this.purchaseRequestKPI,
  });

  final PurchaseRequestKPI purchaseRequestKPI;

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purchaseRequestKPI.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(
                purchaseRequestKPI.number.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              const Icon(
                HugeIcons.strokeRoundedTradeUp,
                color: AppColor.green,
                size: 24.0,
              ),
              Text(
                '${purchaseRequestKPI.percentage}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Text(
              purchaseRequestKPI.feedback,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseRequestKPI {
  const PurchaseRequestKPI({
    required this.title,
    required this.number,
    required this.percentage,
    required this.feedback,
  });

  final String title;
  final int number;
  final double percentage;
  final String feedback;
}
