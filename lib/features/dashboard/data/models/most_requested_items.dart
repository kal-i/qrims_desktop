import '../../domain/entities/most_requested_items.dart';
import 'requested_item.dart';

class MostRequestedItemsModel extends MostRequestedItemsEntity {
  const MostRequestedItemsModel({
    required super.mostRequestedItems,
  });

  factory MostRequestedItemsModel.fromJson(Map<String, dynamic> json) {
    return MostRequestedItemsModel(
      mostRequestedItems: List<RequestedItemModel>.from(
          json["most_requested_items_data"]
              .map((x) => RequestedItemModel.fromJson(x))),
    );
  }
}
