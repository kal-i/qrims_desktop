import 'feedbacks.dart';
import 'purchase_request.dart';

class PaginatedPurchaseRequestResultEntity {
  const PaginatedPurchaseRequestResultEntity({
    required this.totalItemsCount,
    required this.pendingRequestCount,
    required this.incompleteRequestCount,
    required this.completeRequestCount,
    required this.cancelledRequestCount,
    required this.feedbacks,
    required this.purchaseRequests,
  });

  final int totalItemsCount;
  final int pendingRequestCount;
  final int incompleteRequestCount;
  final int completeRequestCount;
  final int cancelledRequestCount;
  final FeedbacksEntity feedbacks;
  final List<PurchaseRequestEntity> purchaseRequests;
}
