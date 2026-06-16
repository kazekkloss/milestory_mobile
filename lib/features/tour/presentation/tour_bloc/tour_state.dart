part of 'tour_bloc.dart';

class TourState extends Equatable {
  final UiEvent? uiEvent;
  final List<Tour> searchedTours;
  final bool loading;

  const TourState({this.uiEvent, required this.searchedTours, required this.loading});

  TourState copyWith({UiEvent? uiEvent, List<Tour>? searchedTours, bool? loading}) {
    return TourState(
      uiEvent: uiEvent,
      searchedTours: searchedTours ?? this.searchedTours,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [uiEvent, searchedTours, loading];
}
