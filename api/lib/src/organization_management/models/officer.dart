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
    this.isArchived = false,
  });

  final String id;
  final String? userId; // nullable because not all officer can be a user, some are just used to be associated with the doc
  final String name; // nullable as well because there will be officers who won't register to the sys, thus we need to include the name field
  final String positionId;
  final String officeName;
  final String positionName;
  final bool isArchived;

  factory Officer.fromJson(Map<String, dynamic> json) {
    return Officer(
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
      'is_archived': false,
    };
  }
}
