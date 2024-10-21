part of 'item_suggestions_bloc.dart';

sealed class ItemSuggestionsEvent extends Equatable {
  const ItemSuggestionsEvent();

  @override
  List<Object?> get props => [];
}

final class FetchItemNames extends ItemSuggestionsEvent {
  const FetchItemNames({
    this.productName,
  });

  final String? productName;

  @override
  List<Object?> get props => [
        productName,
      ];
}

final class FetchItemDescriptions extends ItemSuggestionsEvent {
  const FetchItemDescriptions({
    required this.productName,
    this.productDescription,
  });

  final String productName;
  final String? productDescription;

  @override
  List<Object?> get props => [
        productName,
        productDescription,
      ];
}
