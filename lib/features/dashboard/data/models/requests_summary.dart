import '../../domain/entities/requests_summary.dart';
import 'requested_item.dart';

class RequestsSummaryModel extends RequestsSummaryEntity {
  const RequestsSummaryModel({
    required super.ongoingRequestCount,
    required super.fulfilledRequestCount,
    required super.mostRequestedItems,
  });

  factory RequestsSummaryModel.fromJson(Map<String, dynamic> json) {
    return RequestsSummaryModel(
      ongoingRequestCount: json['ongoing_request_count'],
      fulfilledRequestCount: json['fulfilled_request_count'],
      mostRequestedItems: List<RequestedItemModel>.from(
          json["most_requested_items_data"]
              .map((x) => RequestedItemModel.fromJson(x))),
    );
  }
}
