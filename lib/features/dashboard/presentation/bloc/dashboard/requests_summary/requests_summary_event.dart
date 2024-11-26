part of 'requests_summary_bloc.dart';

sealed class RequestsSummaryEvent extends Equatable {
  const RequestsSummaryEvent();

  @override
  List<Object?> get props => [];
}

final class GetMostRequestedItemsEvent extends RequestsSummaryEvent {
  const GetMostRequestedItemsEvent({this.limit, this.period,});

  final int? limit;
  final Period? period;

  @override
  List<Object?> get props => [
    limit,
    period,
  ];
}
