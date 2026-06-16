import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../tour_export.dart';

part 'tour_event.dart';
part 'tour_state.dart';

@injectable
class TourBloc extends Bloc<TourEvent, TourState> {
  final SearchTour _searchTour;

  TourBloc({required this._searchTour})
    : super(const TourState(searchedTours: [], loading: false)) {
    on<SearchTourEvent>(_searchTourToState);
  }

  void _searchTourToState(
    SearchTourEvent event,
    Emitter<TourState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(searchedTours: [], loading: false));
      return;
    }

    try {
      emit(state.copyWith(uiEvent: null, loading: true));

      final response = await _searchTour
          .call(query: event.query)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                const DataFailed(UiEvent(message: 'Request timeout')),
          );
      if (response is DataSuccess) {
        emit(state.copyWith(searchedTours: response.data!, loading: false));
        print(
          "Search successful: Found ${response.data!.length} tours for query '${event.query}'",
        );
      } else {
        emit(state.copyWith(uiEvent: response.uiEvent, loading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(loading: false, uiEvent: UiEvent(message: e.toString())),
      );
    }
  }
}
