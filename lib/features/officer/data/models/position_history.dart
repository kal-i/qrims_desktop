import '../../domain/entities/position_history.dart';

class PositionHistoryModel extends PositionHistoryEntity {
  const PositionHistoryModel({
    required super.id,
    required super.officerId,
    required super.positionId,
    required super.officeName,
    required super.positionName,
    required super.createdAt,
  });

  factory PositionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PositionHistoryModel(
      id: json['id'],
      officerId: json['officer_id'],
      positionId: json['position_id'],
      officeName: json['office_name'],
      positionName: json['position_name'],
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
