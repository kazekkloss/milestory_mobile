import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'core/core_export.dart';
import 'features/auth/auth_export.dart';
import 'package:milestory_mobile/core/di/injection.dart' as di;


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await di.init();

    runApp(MyApp());
  } catch (e) {
    debugPrint('Błąd podczas inicjalizacji aplikacji: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => GetIt.I<AuthBloc>())],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Flutter Demo',
            theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
            routerConfig: AppRouter(context: context).router,
            debugShowCheckedModeBanner: false,
          );
        }
      ),
    );
  }
}
