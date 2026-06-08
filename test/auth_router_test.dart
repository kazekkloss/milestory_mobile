import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milestory_mobile/core/core_export.dart';
import 'package:milestory_mobile/features/auth/auth_export.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<DataState<User>> checkAuth() async {
    return DataFailed(UiEvent(message: 'failed'));
  }
}

class _FakeCheckAuth extends CheckAuth {
  _FakeCheckAuth() : super(_FakeAuthRepository());
}

void main() {
  testWidgets(
    'redirects to auth screen when auth bloc becomes unauthenticated',
    (tester) async {
      final authBloc = AuthBloc(checkAuth: _FakeCheckAuth());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: Builder(
            builder: (context) => MaterialApp.router(
              routerConfig: AppRouter(context: context).router,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Auth Screen'), findsOneWidget);
    },
  );
}
