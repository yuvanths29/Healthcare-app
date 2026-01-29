import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tabs/family_member_screen.dart';
import 'screens/tabs/family_screen.dart';
import 'screens/tabs/home_screen.dart';
import 'screens/tabs/profile_screen.dart';
import 'screens/tabs/scan_screen.dart';
import 'screens/tabs/tabs_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/reset-password';
      final isSplashRoute = state.matchedLocation == '/';

      // If still loading but on splash, allow it briefly then timeout
      if (isLoading && isSplashRoute) {
        // Splash shown for up to 5 seconds (timeout is in auth_provider)
        return null;
      }

      // If loading (shouldn't happen due to timeout) but not on splash, go to login
      if (isLoading) {
        return '/login';
      }

      // Redirect to login if not logged in and not already on login
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // Redirect to home if logged in and on login page
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => TabsScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/family',
            builder: (context, state) => const FamilyScreen(),
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/family-member/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FamilyMemberScreen(memberId: id);
        },
      ),
    ],
  );
});
