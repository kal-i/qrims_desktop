import '../../../purchase_request/domain/entities/purchase_request.dart';
import 'matched_item.dart';

class MatchedItemWithPrEntity {
  const MatchedItemWithPrEntity({
    required this.purchaseRequestEntity,
    //this.matchedItemEntity,
  });

  final PurchaseRequestEntity purchaseRequestEntity;
  //final List<MatchedItemEntity>? matchedItemEntity;
}
