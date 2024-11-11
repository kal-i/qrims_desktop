import '../../domain/entities/matched_item.dart';

class MatchedItemModel extends MatchedItemEntity {
  const MatchedItemModel({
    required super.itemId,
    required super.issuedQuantity,
  });

  factory MatchedItemModel.fromJson(Map<String, dynamic> json) {
    return MatchedItemModel(
      itemId: json['item_id'] as String,
      issuedQuantity: json['issued_quantity'] as int,
    );
  }
}
