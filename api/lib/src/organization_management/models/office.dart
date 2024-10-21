class Office {
  const Office({
    required this.id,
    required this.officeName,
  });

  final String id;
  final String officeName;

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['office_id'] as String,
      officeName: json['office_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'office_id': id,
      'office_name': officeName,
    };
  }
}