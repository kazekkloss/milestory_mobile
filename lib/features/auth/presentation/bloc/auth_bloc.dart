import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../auth_export.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuth _checkAuth;
  final Login _login;
  final Logout _logout;
  final Register _register;
  final SendPasswordRecoveryLink _sendPasswordRecoveryLink;
  final DeleteUser _deleteUser;

  AuthBloc({
    required this._checkAuth,
    required this._login,
    required this._logout,
    required this._register,
    required this._sendPasswordRecoveryLink,
    required this._deleteUser,
  }) : super(const AuthState.unknown()) {
    on<CheckAuthEvent>(_checkAuthToState);
    on<LoginEvent>(_loginToState);
    on<LogoutEvent>(_logoutToState);
    on<RegistrationEvent>(_registrationEventToState);
    on<SendPasswordRecoveryLinkEvent>(_sendPasswordRecoveryLinkToState);
    on<DeleteAccountEvent>(_deleteAccountToState);
  }

  void _checkAuthToState(CheckAuthEvent event, Emitter<AuthState> emit) async {
    try {
      print("Checking authentication status...");
      if (state.uiEvent != null) {
        emit(state.copyWith(uiEvent: null));
      }
      final response = await _checkAuth.call().timeout(
        const Duration(seconds: 10),
        onTimeout: () => const DataFailed(UiEvent(message: 'Request timeout')),
      );

      print("Authentication check response: $response");
      if (response is DataSuccess) {
        if (response.data!.verify == true) {
          emit(
            AuthState.authenticated(response.data!).copyWith(loading: false),
          );
        } else {
          emit(const AuthState.unauthenticated());
          print("Authentication failed: User not verified");
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  void _loginToState(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(uiEvent: null, loading: true));
      final response = await _login.call(
        email: event.email,
        password: event.password,
      );

      print("Login response: $response");

      if (response is DataSuccess) {
        if (response.data!.verify == true) {
          emit(
            AuthState.authenticated(response.data!).copyWith(loading: false),
          );
        } else {
          emit(
            state.copyWith(
              loading: false,
              uiEvent: const UiEvent(
                message: "Potwierdź konto przez otrzymaną wiadomość email",
                isError: false,
              ),
            ),
          );
        }
      } else {
        emit(state.copyWith(uiEvent: response.uiEvent, loading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          uiEvent: const UiEvent(message: "Błąd logowania. Spróbuj ponownie."),
        ),
      );
    }
  }

  void _logoutToState(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      if (state.uiEvent != null) {
        emit(state.copyWith(uiEvent: null));
      }
      final response = await _logout.call(isLocal: event.isLocal);
      if (response is DataSuccess) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(state.copyWith(uiEvent: response.uiEvent));
      }
    } catch (e) {
      emit(state.copyWith(uiEvent: UiEvent(message: e.toString())));
    }
  }

  void _registrationEventToState(
    RegistrationEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          uiEvent: null,
          loading: true,
          registrationSuccess: false,
        ),
      );
      final response = await _register.call(
        email: event.email,
        password: event.password,
      );
      if (response is DataSuccess) {
        emit(state.copyWith(loading: false, registrationSuccess: true));
      } else {
        emit(state.copyWith(uiEvent: response.uiEvent, loading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(loading: false, uiEvent: UiEvent(message: e.toString())),
      );
    }
  }

  void _sendPasswordRecoveryLinkToState(
    SendPasswordRecoveryLinkEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          uiEvent: null,
          loading: true,
          passwordRecoverySent: false,
        ),
      );
      final response = await _sendPasswordRecoveryLink.call(email: event.email);
      if (response is DataSuccess) {
        emit(
          state.copyWith(
            loading: false,
            passwordRecoverySent: true,
            uiEvent: UiEvent.success(
              message: 'Link wysłany na ${event.email}. Sprawdź skrzynkę.',
            ),
          ),
        );
      } else {
        emit(state.copyWith(loading: false, uiEvent: response.uiEvent));
      }
    } catch (e) {
      emit(
        state.copyWith(loading: false, uiEvent: UiEvent(message: e.toString())),
      );
    }
  }

  Future<void> _deleteAccountToState(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(uiEvent: null, deleteAccountLoading: true));
      final response = await _deleteUser.call(userId: state.user.id);
      if (response is DataSuccess) {
        emit(
          const AuthState.unauthenticated().copyWith(
            uiEvent: const UiEvent(
              message: 'Konto zostało pomyślnie usunięte',
              isError: false,
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            deleteAccountLoading: false,
            uiEvent: response.uiEvent,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          deleteAccountLoading: false,
          uiEvent: UiEvent(message: e.toString()),
        ),
      );
    }
  }
}
