enum Action {
  create,
  update,
  unknown,
}

class UserActivity {
  const UserActivity({
    required this.id,
    required this.userId,
    required this.description,
    required this.actionType,
    this.targetId,
    required this.createdAt,
  });

  final int id;
  final String userId;
  final String description;
  final Action actionType;
  final int? targetId;
  final DateTime createdAt;

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    final actionTypeString = json['action_type'] as String;
    /// extract prefix value if present
    final actionTypeValue = actionTypeString.startsWith('Action.') ? actionTypeString.substring(6) : actionTypeString;
    /// iterate through the Action enum, extract last part then compare to the retrieved action type string
    final actionType = Action.values.firstWhere((e) => e.toString().split('.').last == actionTypeValue, orElse: () => Action.unknown,);


    return UserActivity(
      id: json['user_act_id'] as int,
      userId: json['user_id'] as String,
      description: json['description'] as String,
      actionType: actionType,
      targetId: json['target_id'] != null ? json['target_id'] as int : null,
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_act_id': id,
      'user_id': userId,
      'description': description,
      'action_type': actionType.toString().split('.').last,
      'target_id': targetId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
