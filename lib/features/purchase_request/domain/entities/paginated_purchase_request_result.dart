import 'purchase_request.dart';

class PaginatedPurchaseRequestResultEntity {
  const PaginatedPurchaseRequestResultEntity({
    required this.purchaseRequests,
    required this.totalItemsCount,
  });

  final List<PurchaseRequestEntity> purchaseRequests;
  final int totalItemsCount;
}
