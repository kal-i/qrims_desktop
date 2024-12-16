import 'requested_item.dart';

class RequestsSummaryEntity {
  const RequestsSummaryEntity({
    required this.ongoingRequestCount,
    required this.fulfilledRequestCount,
    required this.mostRequestedItems,
  });

  final int ongoingRequestCount;
  final int fulfilledRequestCount;
  final List<RequestedItemEntity> mostRequestedItems;
}
