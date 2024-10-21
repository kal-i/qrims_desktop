import 'package:equatable/equatable.dart';

class OfficeEntity extends Equatable {
  const OfficeEntity({
    required this.id,
    required this.officeName,
  });

  final String id;
  final String officeName;

  @override
  List<Object?> get props => [
        id,
        officeName,
      ];
}
