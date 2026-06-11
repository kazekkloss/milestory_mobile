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

  GoRouter _router() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteConstants.splashPath,
      refreshListenable: RouterRefreshMultiBloc([
        RouterRefreshBloc<AuthBloc, AuthState>(
          BlocProvider.of<AuthBloc>(context, listen: false),
        ),
      ]),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final loc = state.matchedLocation;
        final isSplash = loc == RouteConstants.splashPath;

        switch (authState.status) {
          case AuthStatus.unknown:
            return isSplash ? null : RouteConstants.splashPath;

          case AuthStatus.unauthenticated:
            return loc == RouteConstants.authPath ? null : RouteConstants.authPath;

          case AuthStatus.authenticated:
            return isSplash || loc == RouteConstants.authPath
                ? RouteConstants.homePath
                : null;
        }
      },
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.splash,
          path: RouteConstants.splashPath,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.auth,
          path: RouteConstants.authPath,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: RouteConstants.home,
          path: RouteConstants.homePath,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }

  GoRouter get router => _router();
}
