/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : app_router.dart
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/admin/admin_application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/shared/splash_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/student_home_screen.dart';
import '../utils/app_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());

      case AppRoutes.login:
        return _fade(const LoginScreen());

      case AppRoutes.register:
        return _fade(const RegisterScreen());

      case AppRoutes.studentHome:
        return _fade(const StudentHomeScreen());

      case AppRoutes.applicationForm:
        return _slide(const ApplicationFormScreen());

      case AppRoutes.applicationDetail:
        final id = settings.arguments as String;
        return _slide(ApplicationDetailScreen(applicationId: id));

      case AppRoutes.adminDashboard:
        return _fade(const AdminDashboardScreen());

      case AppRoutes.adminApplicationDetail:
        final id = settings.arguments as String;
        return _slide(AdminApplicationDetailScreen(applicationId: id));

      default:
        return _fade(const LoginScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: anim.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

/// AuthGuard widget — redirects unauthenticated users to login,
/// and redirects wrong-role users to the correct portal.
class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, auth, __) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }
        if (requireAdmin && !auth.isAdmin) {
          return const StudentHomeScreen();
        }
        if (!requireAdmin && auth.isAdmin) {
          return const AdminDashboardScreen();
        }
        return child;
      },
    );
  }
}
