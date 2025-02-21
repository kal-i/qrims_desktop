import '../../domain/entities/weekly_item_trend.dart';

class WeeklyItemTrendModel extends WeeklyItemTrendEntity {
  const WeeklyItemTrendModel({
    required super.weekStart,
    required super.itemType,
    required super.totalQuantity,
  });

  factory WeeklyItemTrendModel.fromJson(Map<String, dynamic> json) {
    return WeeklyItemTrendModel(
      weekStart: json['week_start'] is String
          ? DateTime.parse(json['week_start'] as String)
          : json['week_start'] as DateTime,
      itemType: json['item_type'],
      totalQuantity: json['total_quantity'],
    );
  }
}
