import 'package:equatable/equatable.dart';

class ManufacturerEntity extends Equatable {
  const ManufacturerEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}
