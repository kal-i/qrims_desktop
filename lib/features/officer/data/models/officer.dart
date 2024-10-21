import '../../domain/entities/officer.dart';

class OfficerModel extends OfficerEntity {
  const OfficerModel({
    required super.id,
    super.userId,
    required super.name,
    required super.positionId,
    required super.officeName,
    required super.positionName,
    super.isArchived,
  });

  factory OfficerModel.fromJson(Map<String, dynamic> json) {
    return OfficerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      positionId: json['position_id'] as String,
      officeName: json['office_name'] as String,
      positionName: json['position_name'] as String,
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
      'is_archived': isArchived,
    };
  }
}
