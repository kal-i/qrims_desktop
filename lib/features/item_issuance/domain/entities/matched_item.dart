/// represents the item from items table matching with the pr
class MatchedItemEntity {
  const MatchedItemEntity({
    required this.itemId,
    required this.issuedQuantity,
  });

  final String itemId;
  final int issuedQuantity;
}