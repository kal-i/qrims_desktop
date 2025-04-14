class Office {
  const Office({
    required this.id,
    required this.officeName,
  });

  final String id;
  final String officeName;

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
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
