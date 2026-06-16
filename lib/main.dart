import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:milestory_mobile/features/tour/presentation/tour_bloc/tour_bloc.dart';
import 'core/core_export.dart';
import 'features/auth/auth_export.dart';
import 'package:milestory_mobile/core/di/injection.dart' as di;

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
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = GetIt.I<AuthBloc>();
    _tourBloc = GetIt.I<TourBloc>();
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
