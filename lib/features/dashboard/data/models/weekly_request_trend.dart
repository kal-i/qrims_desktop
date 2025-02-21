import '../../domain/entities/weekly_request_trend.dart';

class WeeklyRequestTrendModel extends WeeklyRequestTrendEntity {
  const WeeklyRequestTrendModel({
    required super.weekStart,
    required super.status,
    required super.requestCount,
  });

  factory WeeklyRequestTrendModel.fromJson(Map<String, dynamic> json) {
    return WeeklyRequestTrendModel(
      weekStart: json['week_start'] is String
          ? DateTime.parse(json['week_start'] as String)
          : json['week_start'] as DateTime,
      status: json['status'],
      requestCount: json['request_count'],
    );
  }
}
