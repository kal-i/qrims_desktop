import '../../domain/entities/paginated_purchase_request_result.dart';
import 'feedbacks.dart';
import 'purchase_request.dart';

class PaginatedPurchaseRequestResultModel
    extends PaginatedPurchaseRequestResultEntity {
  const PaginatedPurchaseRequestResultModel({
    required super.totalItemsCount,
    required super.pendingRequestCount,
    required super.incompleteRequestCount,
    required super.completeRequestCount,
    required super.cancelledRequestCount,
    required super.feedbacks,
    required super.purchaseRequests,
  });

  factory PaginatedPurchaseRequestResultModel.fromJson(
      Map<String, dynamic> json) {
    return PaginatedPurchaseRequestResultModel(
      totalItemsCount: json['totalItemCount'],
      pendingRequestCount: json['pending_count'],
      incompleteRequestCount: json['partially_fulfilled_count'],
      completeRequestCount: json['fulfilled_count'],
      cancelledRequestCount: json['cancelled_count'],
      feedbacks: FeedbacksModel.fromJson(json['feedbacks']),
      purchaseRequests: (json['purchase_requests'] as List<dynamic>)
          .map((e) => PurchaseRequestModel.fromJson(e))
          .toList(),
    );
  }
}
