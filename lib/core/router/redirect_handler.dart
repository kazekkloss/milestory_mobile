import 'package:go_router/go_router.dart';
import '../../features/auth/auth_export.dart';
import '../core_export.dart';

class RedirectHandler {
  final AuthBloc _authBloc;

  RedirectHandler(this._authBloc);

  String? handleRedirect(GoRouterState state) {
    final loc = state.matchedLocation;

    switch (_authBloc.state.status) {
      case AuthStatus.unknown:
        return loc == RouteConstants.splashPath ? null : RouteConstants.splashPath;

      case AuthStatus.unauthenticated:
        return loc == RouteConstants.authPath ? null : RouteConstants.authPath;

      case AuthStatus.authenticated:
        if (loc == RouteConstants.splashPath || loc == RouteConstants.authPath) {
          return RouteConstants.homePath;
        }
        return null;
    }
  }
}
