part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {}

class CheckAuthEvent extends AuthEvent {
  CheckAuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegistrationEvent extends AuthEvent {
  final String email;
  final String password;

  RegistrationEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {
  final bool isLocal;
  LogoutEvent({required this.isLocal});

  @override
  List<Object?> get props => [isLocal];
}

class SendPasswordRecoveryLinkEvent extends AuthEvent {
  final String email;
  SendPasswordRecoveryLinkEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class DeleteAccountEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}
