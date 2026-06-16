import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../map_export.dart';

part 'map_event.dart';
part 'map_state.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetTourPoints _getTourPoints;

  MapBloc({required this._getTourPoints}) : super(MapState.initial()) {
    on<GetTourPointsEvent>(_onGetTourPoints);
  }

  void _onGetTourPoints(
    GetTourPointsEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(uiEvent: null));

    final response = await _getTourPoints(tourId: event.tourId);
    if (response is DataSuccess) {
      print(response);

      emit(state.copyWith(tourPoints: response.data));
    } else {
      emit(state.copyWith(uiEvent: response.uiEvent));
    }
  }
}
