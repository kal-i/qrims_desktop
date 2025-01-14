class PositionHistoryEntity {
  const PositionHistoryEntity({
    required this.id,
    required this.officerId,
    required this.positionId,
    required this.officeName,
    required this.positionName,
    required this.createdAt,
  });

  final int id;
  final String officerId;
  final String positionId;
  final String officeName;
  final String positionName;
  final DateTime createdAt;
}
