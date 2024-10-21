import '../../domain/entities/position.dart';

class PositionModel extends PositionEntity {
  const PositionModel({
    required super.id,
    required super.officeId,
    required super.positionName,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'] as String,
      officeId: json['office_id'] as String,
      positionName: json['position_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'office_id': officeId,
      'position_name': positionName,
    };
  }
}
