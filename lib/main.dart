// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';

// Local
import 'core/core_export.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/auth_export.dart';
import 'features/map/map_export.dart';
import 'features/tour/tour_export.dart';

void main() async {
  try {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await dotenv.load(fileName: ".env");
    await di.init();

    runApp(const MileStoryApp());
  } catch (e, stack) {
    debugPrint('Błąd podczas inicjalizacji: $e\n$stack');
    FlutterNativeSplash.remove();
    runApp(_ErrorApp(message: e.toString()));
  }
}

class MileStoryApp extends StatefulWidget {
  const MileStoryApp({super.key});

  @override
  State<MileStoryApp> createState() => _MileStoryAppState();
}

class _MileStoryAppState extends State<MileStoryApp> {
  late final AuthBloc _authBloc;
  late final TourBloc _tourBloc;
  late final MapBloc _mapBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = GetIt.I<AuthBloc>();
    _tourBloc = GetIt.I<TourBloc>();
    _mapBloc = GetIt.I<MapBloc>();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _tourBloc),
        BlocProvider.value(value: _mapBloc),
      ],
      child: MaterialApp.router(
        theme: CustomTheme.darkTheme,
        title: 'MileStory',
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Błąd inicjalizacji aplikacji:\n\n$message',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
