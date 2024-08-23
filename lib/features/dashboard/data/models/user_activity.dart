import '../../../../core/enums/action.dart';
import '../../domain/entities/user_activity.dart';

class UserActivityModel extends UserActivityEntity {
  const UserActivityModel({
    required super.id,
    required super.userId,
    required super.description,
    required super.actionType,
    super.targetId,
    required super.createdAt,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    final actionTypeString = json['action_type'] as String;
    final actionTypeValue = actionTypeString.startsWith('Action.') ? actionTypeString.substring(7) : actionTypeString;
    final actionType = Action.values.firstWhere((e) => e.toString().split('.').last == actionTypeValue, orElse: () => Action.unknown,);

    return UserActivityModel(
      id: json['user_act_id'],
      userId: json['user_id'],
      description: json['description'],
      actionType: actionType,
      targetId: json['target_id'],
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : json['created_at'] as DateTime,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_act_id': id,
      'user_id': userId,
      'description': description,
      'action_type': actionType,
      'target_id': targetId,
      'created_at': createdAt,
    };
  }
}
