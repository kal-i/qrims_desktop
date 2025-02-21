import 'package:flutter/material.dart';

import '../../domain/entities/reusable_item_information.dart';

class ReusableItemInformationContainer extends StatelessWidget {
  const ReusableItemInformationContainer({
    super.key,
    required this.reusableItemInformationEntity,
  });

  final ReusableItemInformationEntity reusableItemInformationEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                reusableItemInformationEntity.productName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                reusableItemInformationEntity.productDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                reusableItemInformationEntity.specifciation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (reusableItemInformationEntity.quantity != null)
              Expanded(
                child: Text(
                  reusableItemInformationEntity.quantity.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        SizedBox(
          height: 10.0,
          child: Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.5,
          ),
        ),
      ],
    );
  }
}
