import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_export.dart';
import '../../features/home/home_export.dart';
import '../core_export.dart';

class AppRouter {
  final BuildContext context;
  AppRouter({required this.context});
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  //final _shellNavigatorKey = GlobalKey<NavigatorState>();

  GoRouter _router() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: RouterRefreshMultiBloc([
          RouterRefreshBloc<AuthBloc, AuthState>(
              BlocProvider.of<AuthBloc>(context, listen: false)),
        ]),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final loc = state.matchedLocation;

        final isSplash = loc == '/splash';
        final isWelcome = loc == '/auth';

        switch (authState.status) {
          case AuthStatus.unknown:
            return isSplash ? null : '/splash';

          case AuthStatus.unauthenticated:
            return isWelcome ? null : '/auth';

          case AuthStatus.authenticated:
            if (isSplash || isWelcome) return '/home';
            // final guideUser = context.read<GuideUserBloc>().state.guideUser;
            // if (loc.startsWith('/dashboard') &&
            //     !guideUser.hasSeenCreatorOnboarding) {
            //   return '/creator-onboarding';
            // }
            return null;
        }
      },

      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.splash,
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.auth,
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          name: RouteConstants.home,
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }

  GoRouter get router => _router();
}
