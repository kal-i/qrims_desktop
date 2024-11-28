part of 'purchase_requests_bloc.dart';

sealed class PurchaseRequestsState extends Equatable {
  const PurchaseRequestsState();

  @override
  List<Object?> get props => [];
}

final class PurchaseRequestsInitial extends PurchaseRequestsState {}

final class PurchaseRequestsLoading extends PurchaseRequestsState {}

final class PurchaseRequestsLoaded extends PurchaseRequestsState {
  const PurchaseRequestsLoaded({
    required this.totalPurchaseRequestsCount,
    required this.pendingRequestsCount,
    required this.incompleteRequestCount,
    required this.completeRequestsCount,
    required this.cancelledRequestsCount,
    required this.feedbacks,
    required this.purchaseRequests,
  });

  final int totalPurchaseRequestsCount;
  final int pendingRequestsCount;
  final int incompleteRequestCount;
  final int completeRequestsCount;
  final int cancelledRequestsCount;
  final FeedbacksEntity feedbacks;
  final List<PurchaseRequestEntity> purchaseRequests;

  @override
  List<Object?> get props => [
        purchaseRequests,
        totalPurchaseRequestsCount,
      ];
}

final class PurchaseRequestRegistered extends PurchaseRequestsState {
  const PurchaseRequestRegistered({
    required this.purchaseRequest,
  });

  final PurchaseRequestEntity purchaseRequest;
}

final class PurchaseRequestsError extends PurchaseRequestsState {
  const PurchaseRequestsError({
    required this.message,
  });

  final String message;
}

final class PurchaseRequestStatusUpdated extends PurchaseRequestsState {
  const PurchaseRequestStatusUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;
}

final class PurchaseRequestLoaded extends PurchaseRequestsState {
  const PurchaseRequestLoaded({
    required this.purchaseRequestWithNotificationTrailEntity,
  });

  final PurchaseRequestWithNotificationTrailEntity purchaseRequestWithNotificationTrailEntity;
}
