import '../../domain/entities/fulfilled_request_trend.dart';

class FulfilledRequestTrendModel extends FulfilledRequestTrendEntity {
  FulfilledRequestTrendModel({
    required super.date,
    required super.requestCount,
  });

  factory FulfilledRequestTrendModel.fromJson(Map<String, dynamic> json) {
    return FulfilledRequestTrendModel(
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : json['date'] as DateTime,
      requestCount: json['count'],
    );
  }
}
