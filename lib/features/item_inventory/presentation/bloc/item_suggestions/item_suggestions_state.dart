part of 'item_suggestions_bloc.dart';

sealed class ItemSuggestionsState extends Equatable {
  const ItemSuggestionsState();

  @override
  List<Object?> get props => [];
}

final class ItemSuggestionsInitial extends ItemSuggestionsState {}

final class ItemSuggestionsLoading extends ItemSuggestionsState {}

final class ItemSuggestionsError extends ItemSuggestionsState {
  const ItemSuggestionsError({
    required this.message,
  });

  final String message;
}

final class ItemNamesLoaded extends ItemSuggestionsState {
  const ItemNamesLoaded({
    required this.itemNames,
  });

  final List<String> itemNames;

  @override
  List<Object?> get props => [
        itemNames,
      ];
}

final class ItemDescriptionsLoaded extends ItemSuggestionsState {
  const ItemDescriptionsLoaded({
    required this.itemDescriptions,
  });

  final List<String> itemDescriptions;

  @override
  List<Object?> get props => [
        itemDescriptions,
      ];
}
