class WeeklyRequestTrendEntity {
  const WeeklyRequestTrendEntity({
    required this.weekStart,
    required this.status,
    required this.requestCount,
  });

  final DateTime weekStart;
  final String status;
  final int requestCount;
}
