import 'requested_item_data.dart';

class RequestedItemEntity {
  const RequestedItemEntity({
    required this.productName,
    required this.requestedItemData,
  });

  final String productName;
  final List<RequestedItemDataEntity> requestedItemData;
}
