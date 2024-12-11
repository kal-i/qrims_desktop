import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../data/models/feedback.dart';

class PurchaseRequestKPICard extends StatelessWidget {
  const PurchaseRequestKPICard({
    super.key,
    required this.title,
    required this.count,
    required this.feedback,
  });

  final String title;
  final int count;
  final FeedbackModel? feedback;

  @override
  Widget build(BuildContext context) {
    print('percentage: ${feedback?.percentage}');
    return BaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              if (feedback?.isIncrease != null)
                Icon(
                  feedback!.isIncrease! ? HugeIcons.strokeRoundedTradeUp : HugeIcons.strokeRoundedTradeDown,
                  color: feedback!.isIncrease! ? AppColor.green : AppColor.red,
                  size: 24.0,
                ),
              Text(
                '${feedback?.percentage.toStringAsFixed(1) ?? 0.0}%',
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
              feedback?.feedback ?? 'Initializing summary information...',
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
