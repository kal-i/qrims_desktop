import '../../domain/entities/requested_item_data.dart';

class RequestedItemDataModel extends RequestedItemDataEntity {
  const RequestedItemDataModel({
    required super.date,
    required super.quantity,
  });

  factory RequestedItemDataModel.fromJson(Map<String, dynamic> json) {
    return RequestedItemDataModel(
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
    );
  }
}
