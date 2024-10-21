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
    required this.purchaseRequests,
    required this.totalPurchaseRequestsCount,
  });

  final List<PurchaseRequestEntity> purchaseRequests;
  final int totalPurchaseRequestsCount;

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
