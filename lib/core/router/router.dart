import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milestory_mobile/core/router/redirect_handler.dart';

import '../../features/auth/auth_export.dart';
import '../../features/map/map_export.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/tour/tour_export.dart';
import '../../features/saved/saved_export.dart';
import '../core_export.dart';

class AppRouter {
  final AuthBloc _authBloc;
  late final RouterRefreshBloc<AuthBloc, AuthState> _refreshBloc;

  AppRouter({required AuthBloc authBloc}) : _authBloc = authBloc {
    _refreshBloc = RouterRefreshBloc(_authBloc);
  }

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  int _currentTabIndex = 0;
  int _previousTabIndex = 0;

  final tabs = const [
    NavBarItem(initialLocation: RouteConstants.homePath, icon: Icon(Icons.home), label: ''),
    NavBarItem(initialLocation: RouteConstants.savedPath, icon: Icon(Icons.bookmark_outline), label: ''),
    NavBarItem(initialLocation: RouteConstants.profilePath, icon: Icon(Icons.person_outline), label: ''),
  ];

  late final Map<int, Widget> _screens = {
    0: const TourScreen(),
    1: const SavedScreen(),
    2: const ProfileScreen(),
  };

  late final GoRouter router = _buildRouter();

  GoRouter _buildRouter() {
    final redirectHandler = RedirectHandler(_authBloc);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteConstants.splashPath,
      refreshListenable: _refreshBloc,
      redirect: (context, state) => redirectHandler.handleRedirect(state),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: RouteConstants.splashPath,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: RouteConstants.authPath,
          builder: (context, state) => const AuthScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state, child) {
            return CustomAnimationPage(
              child: NavBar(tabs: tabs, child: child),
            );
          },
          routes: [
            GoRoute(
              path: RouteConstants.homePath,
              pageBuilder: (context, state) {
                _previousTabIndex = _currentTabIndex;
                _currentTabIndex = 0;
                return CustomShellAnimationPage(
                  key: state.pageKey,
                  child: _screens[0]!,
                  currentIndex: _currentTabIndex,
                  previousIndex: _previousTabIndex,
                  previousScreen: _screens[_previousTabIndex],
                );
              },
              routes: [
                GoRoute(
                  path: 'tour/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => TourDetailScreen(
                    tour: state.extra as Tour,
                  ),
                  routes: [
                    GoRoute(
                      path: 'map',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => TourMapScreen(
                        tour: state.extra as Tour,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: RouteConstants.savedPath,
              pageBuilder: (context, state) {
                _previousTabIndex = _currentTabIndex;
                _currentTabIndex = 1;
                return CustomShellAnimationPage(
                  key: state.pageKey,
                  child: _screens[1]!,
                  currentIndex: _currentTabIndex,
                  previousIndex: _previousTabIndex,
                  previousScreen: _screens[_previousTabIndex],
                );
              },
            ),
            GoRoute(
              path: RouteConstants.profilePath,
              pageBuilder: (context, state) {
                _previousTabIndex = _currentTabIndex;
                _currentTabIndex = 2;
                return CustomShellAnimationPage(
                  key: state.pageKey,
                  child: _screens[2]!,
                  currentIndex: _currentTabIndex,
                  previousIndex: _previousTabIndex,
                  previousScreen: _screens[_previousTabIndex],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void dispose() {
    router.dispose();
    _refreshBloc.dispose();
  }
}
