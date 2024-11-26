import '../../domain/entities/requested_item.dart';
import 'requested_item_data.dart';

class RequestedItemModel extends RequestedItemEntity {
  const RequestedItemModel({
    required super.productName,
    required super.requestedItemData,
  });

  factory RequestedItemModel.fromJson(Map<String, dynamic> json) =>
      RequestedItemModel(
        productName: json["product_name"],
        requestedItemData: List<RequestedItemDataModel>.from(
            json["data"].map((x) => RequestedItemDataModel.fromJson(x))),
      );
}
