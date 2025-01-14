class PositionHistory {
  const PositionHistory({
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

  factory PositionHistory.fromJson(Map<String, dynamic> json) {
    return PositionHistory(
      id: json['id'] as int,
      officerId: json['officer_id'] as String,
      positionId: json['position_id'] as String,
      officeName: json['office_name'] as String,
      positionName: json['position_name'] as String,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officer_id': officerId,
      'position_id': positionId,
      'office_name': officeName,
      'position_name': positionName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
