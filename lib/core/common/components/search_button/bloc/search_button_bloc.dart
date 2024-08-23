import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_button_event.dart';
part 'search_button_state.dart';

class SearchButtonBloc extends Bloc<SearchButtonEvent, SearchButtonState> {
  SearchButtonBloc() : super(SearchButtonCollapsed()) {
    on<ToggleExpand>(_onToggleExpand);
  }

  void _onToggleExpand(ToggleExpand event, Emitter<SearchButtonState> emit) {
    emit(
      state is SearchButtonCollapsed
          ? SearchButtonExpanded()
          : SearchButtonCollapsed(),
    );
  }
}
