class Position {
  const Position({
    required this.id,
    required this.officeId,
    required this.positionName,
  });

  final String id;
  final String officeId;
  final String positionName;

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
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