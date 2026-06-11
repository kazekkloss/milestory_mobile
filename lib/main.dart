import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'core/core_export.dart';
import 'features/auth/auth_export.dart';
import 'package:milestory_mobile/core/di/injection.dart' as di;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await dotenv.load(fileName: ".env");
    await di.init();

    runApp(const MileStoryApp());
  } catch (e, stack) {
    debugPrint('Błąd podczas inicjalizacji: $e\n$stack');
    runApp(_ErrorApp(message: e.toString()));
  }
}

class MileStoryApp extends StatelessWidget {
  const MileStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetIt.I<AuthBloc>()..add(CheckAuthEvent()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            theme: CustomTheme.darkTheme,
            title: 'MileStory',
            routerConfig: AppRouter(context: context).router,
            debugShowCheckedModeBanner: false,
          );
        },
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
