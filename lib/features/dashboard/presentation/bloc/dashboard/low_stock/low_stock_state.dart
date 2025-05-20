part of 'low_stock_bloc.dart';

sealed class LowStockState extends Equatable {
  const LowStockState();

  @override
  List<Object?> get props => [];
}

final class LowStockInitial extends LowStockState {}

final class LowStockLoading extends LowStockState {}

final class LowStockLoaded extends LowStockState {
  const LowStockLoaded({
    required this.items,
    required this.totalItemsCount,
  });

  final List<ReusableItemInformationEntity> items;
  final int totalItemsCount;

  @override
  List<Object?> get props => [
        items,
        totalItemsCount,
      ];
}

final class LowStockError extends LowStockState {
  const LowStockError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
      ];
}
