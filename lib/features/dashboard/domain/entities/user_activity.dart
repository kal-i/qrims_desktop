import 'package:equatable/equatable.dart';

import '../../../../core/enums/action.dart';

class UserActivityEntity extends Equatable {
  const UserActivityEntity({
    required this.id,
    required this.userId,
    required this.description,
    required this.actionType,
    this.targetId,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String description;
  final Action actionType;
  final int? targetId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    description,
    actionType,
    targetId,
    createdAt,
  ];
}