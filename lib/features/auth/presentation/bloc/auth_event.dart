part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {}

class CheckAuthEvent extends AuthEvent {
  CheckAuthEvent();

  @override
  List<Object?> get props => [];
}
