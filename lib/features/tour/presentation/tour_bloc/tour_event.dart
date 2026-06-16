part of 'tour_bloc.dart';

sealed class TourEvent extends Equatable {
  const TourEvent();

  @override
  List<Object> get props => [];
}

class SearchTourEvent extends TourEvent {
  final String query;

  const SearchTourEvent({required this.query});

  @override
  List<Object> get props => [query];
}
