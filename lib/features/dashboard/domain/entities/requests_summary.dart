import 'fulfilled_request_trend.dart';
import 'most_requested_item.dart';
import 'weekly_request_trend.dart';

class RequestsSummaryEntity {
  const RequestsSummaryEntity({
    required this.ongoingWeeklyTrendEntities,
    required this.fulfilledWeeklyTrendEntities,
    required this.fulfilledRequestTrendEntities,
    required this.mostRequestedItemEntities,
    required this.ongoingPercentageChange,
    required this.fulfilledPercentageChange,
    required this.ongoingRequestCount,
    required this.fulfilledRequestCount,
  });

  final List<WeeklyRequestTrendEntity> ongoingWeeklyTrendEntities;
  final List<WeeklyRequestTrendEntity> fulfilledWeeklyTrendEntities;
  final List<FulfilledRequestTrendEntity> fulfilledRequestTrendEntities;
  final List<MostRequestedItemEntity> mostRequestedItemEntities;
  final double ongoingPercentageChange;
  final double fulfilledPercentageChange;
  final int ongoingRequestCount;
  final int fulfilledRequestCount;
}
