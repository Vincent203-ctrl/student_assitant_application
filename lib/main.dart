/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : main.dart
 * Description    : Entry point for the Student Assistant Application System.
 *                  Initialises Supabase, sets up the Provider tree (MVVM),
 *                  and launches the Flutter app.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'services/supabase_service.dart';
import 'utils/app_constants.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/shared/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise Supabase (reads URL and anon key from .env)
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModel — top-level, shared everywhere
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),

        // Application ViewModel — student CRUD operations
        ChangeNotifierProvider<ApplicationViewModel>(
          create: (_) => ApplicationViewModel(),
        ),

        // Admin ViewModel — admin review operations
        ChangeNotifierProvider<AdminViewModel>(
          create: (_) => AdminViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'SA Portal – TPG316C',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        onGenerateRoute: AppRouter.generateRoute,
        home: const SplashScreen(),
      ),
    );
  }
}
