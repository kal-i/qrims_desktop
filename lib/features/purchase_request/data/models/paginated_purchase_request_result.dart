import '../../domain/entities/paginated_purchase_request_result.dart';
import 'purchase_request.dart';

class PaginatedPurchaseRequestResultModel
    extends PaginatedPurchaseRequestResultEntity {
  const PaginatedPurchaseRequestResultModel({
    required super.purchaseRequests,
    required super.totalItemsCount,
  });

  factory PaginatedPurchaseRequestResultModel.fromJson(
      Map<String, dynamic> json) {
    return PaginatedPurchaseRequestResultModel(
      purchaseRequests: (json['purchase_requests'] as List<dynamic>)
          .map((e) => PurchaseRequestModel.fromJson(e))
          .toList(),
      totalItemsCount: json['totalItemCount'],
    );
  }
}
