/// Represents the Entity or Agency
class Entity {
  const Entity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['entity_id'] as String,
      name: json['entity_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': id,
      'entity_name': name,
    };
  }
}