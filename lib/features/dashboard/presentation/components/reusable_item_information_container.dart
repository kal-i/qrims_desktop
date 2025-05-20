import 'package:flutter/material.dart';

import '../../../../core/utils/capitalizer.dart';
import '../../domain/entities/reusable_item_information.dart';

class ReusableItemInformationContainer extends StatelessWidget {
  const ReusableItemInformationContainer({
    super.key,
    required this.reusableItemInformationEntity,
  });

  final ReusableItemInformationEntity reusableItemInformationEntity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('• '),
              Expanded(
                child: Text(
                  capitalizeWord(reusableItemInformationEntity.productName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  capitalizeWord(
                      reusableItemInformationEntity.productDescription),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              // if (reusableItemInformationEntity.specifciation != null)
              //   Expanded(
              //     child: Text(
              //       capitalizeWord(
              //           reusableItemInformationEntity.specifciation!),
              //       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              //             fontSize: 12.0,
              //             fontWeight: FontWeight.w500,
              //           ),
              //       overflow: TextOverflow.ellipsis,
              //       maxLines: 1,
              //       softWrap: false,
              //     ),
              //   ),
              if (reusableItemInformationEntity.quantity != null)
                Text(
                  reusableItemInformationEntity.quantity.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
