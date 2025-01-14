import '../../../../core/enums/officer_status.dart';
import '../../domain/entities/officer.dart';
import 'position_history.dart';

class OfficerModel extends OfficerEntity {
  const OfficerModel({
    required super.id,
    super.userId,
    required super.name,
    required super.positionId,
    required super.officeName,
    required super.positionName,
    super.status,
    required super.positionHistory,
    super.isArchived,
  });

  factory OfficerModel.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String;

    final status = OfficerStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
    );

    final positionHistory =
        (json['position_history'] as List<dynamic>).map((position) {
      return PositionHistoryModel.fromJson({
        'id': position['id'],
        'officer_id': position['officer_id'],
        'position_id': position['position_id'],
        'office_name': position['office_name'],
        'position_name': position['position_name'],
        'created_at': position['created_at'],
      });
    }).toList();

    return OfficerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      positionId: json['position_id'] as String,
      officeName: json['office_name'] as String,
      positionName: json['position_name'] as String,
      positionHistory: positionHistory,
      status: status,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'position_id': positionId,
      'office_name': officeName,
      'position_name': positionName,
      'status': status.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
