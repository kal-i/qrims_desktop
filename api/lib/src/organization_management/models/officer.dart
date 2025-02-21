import 'package:api/src/organization_management/models/position_history.dart';

enum OfficerStatus {
  active,
  suspended,
  resigned,
  retired,
}

/// Represents the officer associated within
/// the item issuance or document report
class Officer {
  const Officer({
    required this.id,
    this.userId,
    required this.name,
    required this.positionId,
    required this.officeName,
    required this.positionName,
    required this.positionHistory,
    this.status = OfficerStatus.active,
    this.isArchived = false,
  });

  final String id;
  final String?
      userId; // nullable because not all officer can be a user, some are just used to be associated with the doc
  final String
      name; // nullable as well because there will be officers who won't register to the sys, thus we need to include the name field
  final String positionId; // represent the current position id
  final String officeName;
  final String positionName;
  final OfficerStatus status;
  final List<PositionHistory> positionHistory;
  final bool isArchived;

  factory Officer.fromJson(Map<String, dynamic> json) {
    print('raw json received by officer: $json');
    final statusString = json['status'] as String;

    final status = OfficerStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
    );

    print('status from officer: $status');
    print(json['position_history']);

    final positionHistory =
        (json['position_history'] as List<dynamic>).map((position) {
      return PositionHistory.fromJson({
        'id': position['id'],
        'officer_id': position['officer_id'],
        'position_id': position['position_id'],
        'office_name': position['office_name'],
        'position_name': position['position_name'],
        'created_at': position['created_at'],
      });
    }).toList();

    print('pos history: $positionHistory');

    return Officer(
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
      'position_history': positionHistory
          .map(
            (position) => position.toJson(),
          )
          .toList(),
      'status': status.toString().split('.').last,
      'is_archived': false,
    };
  }
}
