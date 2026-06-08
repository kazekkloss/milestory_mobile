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

  AuthBloc({required CheckAuth checkAuth})
    : _checkAuth = checkAuth,
      super(const AuthState.unknown()) {
    on<CheckAuthEvent>(_checkAuthToState);
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
          emit(AuthState.authenticated(response.data!).copyWith(loading: false));
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
}
