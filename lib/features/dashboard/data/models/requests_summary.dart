import '../../domain/entities/requests_summary.dart';
import 'fulfilled_request_trend.dart';
import 'most_requested_item.dart';
import 'weekly_request_trend.dart';

class RequestsSummaryModel extends RequestsSummaryEntity {
  const RequestsSummaryModel({
    required super.ongoingWeeklyTrendEntities,
    required super.fulfilledWeeklyTrendEntities,
    required super.fulfilledRequestTrendEntities,
    required super.mostRequestedItemEntities,
    required super.ongoingPercentageChange,
    required super.fulfilledPercentageChange,
    required super.ongoingRequestCount,
    required super.fulfilledRequestCount,
  });

  factory RequestsSummaryModel.fromJson(Map<String, dynamic> json) {
    print('json received by req summ model:\n\n$json');

    final ongoingWeeklyTrendEntities =
        (json['weekly_trends']['ongoing_trends'] as List)
            .map((e) => WeeklyRequestTrendModel.fromJson(e))
            .toList();

    final fulfilledWeeklyTrendEntities =
        (json['weekly_trends']['fulfilled_trends'] as List)
            .map((e) => WeeklyRequestTrendModel.fromJson(e))
            .toList();

    final fulfilledRequestTrendEntities =
        (json['fulfilled_requests_over_time'] as List)
            .map((e) => FulfilledRequestTrendModel.fromJson(e))
            .toList();

    final mostRequestedItemEntities = (json['most_requested_items'] as List)
        .map((e) => MostRequestedItemModel.fromJson(e))
        .toList();

    final requestSummaryModel = RequestsSummaryModel(
      ongoingWeeklyTrendEntities: ongoingWeeklyTrendEntities,
      fulfilledWeeklyTrendEntities: fulfilledWeeklyTrendEntities,
      fulfilledRequestTrendEntities: fulfilledRequestTrendEntities,
      mostRequestedItemEntities: mostRequestedItemEntities,
      ongoingPercentageChange:
          (json['weekly_trends']['ongoing_percentage_change'] as num)
              .toDouble(),
      fulfilledPercentageChange:
          (json['weekly_trends']['fulfilled_percentage_change'] as num)
              .toDouble(),
      ongoingRequestCount: json['ongoing_request_count'],
      fulfilledRequestCount: json['fulfilled_request_count'],
    );
    print('converted request summary model');
    return requestSummaryModel;
  }
}
