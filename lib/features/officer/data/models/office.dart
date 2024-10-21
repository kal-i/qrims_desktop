import '../../domain/entities/office.dart';

class OfficeModel extends OfficeEntity {
  const OfficeModel({
    required super.id,
    required super.officeName,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: json['id'] as String,
      officeName: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': officeName,
    };
  }
}
