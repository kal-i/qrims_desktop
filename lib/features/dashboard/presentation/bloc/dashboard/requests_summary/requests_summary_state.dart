part of 'requests_summary_bloc.dart';

sealed class RequestsSummaryState extends Equatable {
  const RequestsSummaryState();

  @override
  List<Object?> get props => [];
}

final class RequestsSummaryInitial extends RequestsSummaryState {}

final class RequestsSummaryLoading extends RequestsSummaryState {}

final class RequestsSummaryLoaded extends RequestsSummaryState {
  const RequestsSummaryLoaded({
    required this.mostRequestedItemsEntity,
  });

  final MostRequestedItemsEntity mostRequestedItemsEntity;

  @override
  List<Object?> get props => [
        mostRequestedItemsEntity,
      ];
}

final class RequestsSummaryError extends RequestsSummaryState {
  const RequestsSummaryError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
    message,
  ];
}