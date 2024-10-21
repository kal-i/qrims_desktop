import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_item_suggestion_descriptions.dart';
import '../../../domain/usecases/get_item_suggestion_names.dart';

part 'item_suggestions_event.dart';
part 'item_suggestions_state.dart';

class ItemSuggestionsBloc
    extends Bloc<ItemSuggestionsEvent, ItemSuggestionsState> {
  ItemSuggestionsBloc({
    required GetItemSuggestionNames getItemSuggestionNames,
    required GetItemSuggestionDescriptions getItemSuggestionDescriptions,
  })  : _getItemSuggestionNames = getItemSuggestionNames,
        _getItemSuggestionDescriptions = getItemSuggestionDescriptions,
        super(ItemSuggestionsInitial()) {
    on<FetchItemNames>(_onFetchItemNames);
    on<FetchItemDescriptions>(_onFetchItemDescriptions);
  }

  final GetItemSuggestionNames _getItemSuggestionNames;
  final GetItemSuggestionDescriptions _getItemSuggestionDescriptions;

  void _onFetchItemNames(
    FetchItemNames event,
    Emitter<ItemSuggestionsState> emit,
  ) async {
    emit(ItemSuggestionsLoading());

    final response = await _getItemSuggestionNames(event.productName);

    response.fold(
      (l) => emit(ItemSuggestionsError(message: l.message)),
      (r) => emit(ItemNamesLoaded(itemNames: r)),
    );
  }

  void _onFetchItemDescriptions(
    FetchItemDescriptions event,
    Emitter<ItemSuggestionsState> emit,
  ) async {
    emit(ItemSuggestionsLoading());

    final response = await _getItemSuggestionDescriptions(
      GetItemSuggestionDescriptionsParams(
        productName: event.productName,
        productDescription: event.productDescription,
      ),
    );

    response.fold(
      (l) => emit(ItemSuggestionsError(message: l.message)),
      (r) => emit(ItemDescriptionsLoaded(itemDescriptions: r)),
    );
  }
}
