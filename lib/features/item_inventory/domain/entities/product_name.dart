import 'package:equatable/equatable.dart';

class ProductNameEntity extends Equatable {
  const ProductNameEntity({
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
