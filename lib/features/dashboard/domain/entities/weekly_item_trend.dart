class WeeklyItemTrendEntity {
  const WeeklyItemTrendEntity({
    required this.weekStart,
    required this.itemType,
    required this.totalQuantity,
  });

  final DateTime weekStart;
  final String itemType;
  final int totalQuantity;
}
