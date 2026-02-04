import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/permissions/permissions_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tabs/donation_screen.dart';
import 'screens/tabs/family_member_screen.dart';
import 'screens/tabs/family_screen.dart';
import 'screens/tabs/home_screen.dart';
import 'screens/tabs/profile_screen.dart';
import 'screens/tabs/scan_screen.dart';
import 'screens/tabs/tabs_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref.read(authProvider));
  ref.listen(authProvider, (_, next) {
    print('routerProvider: authProvider changed: $next');
    refresh.update(next);
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = refresh.authState;
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/reset-password';
      final isSplashRoute = state.matchedLocation == '/';

      print(
          'GoRouter redirect: isLoading=$isLoading, isLoggedIn=$isLoggedIn, matchedLocation=${state.matchedLocation}');

      // If still loading, stay on splash
      if (isLoading) {
        print('GoRouter: Still loading, redirecting to splash if not already');
        return isSplashRoute ? null : '/';
      }

      // Redirect to login if not logged in and not already on login/splash
      if (!isLoggedIn && !isLoginRoute && !isSplashRoute) {
        print('GoRouter: Not logged in, redirecting to /login');
        return '/login';
      }

      // If logged in, go to home
      if (isLoggedIn && isSplashRoute) {
        print('GoRouter: Logged in, redirecting to /home');
        return '/home';
      }

      print('GoRouter: No redirect needed');
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
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
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
            path: '/donation',
            builder: (context, state) => const DonationScreen(),
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

class _RouterRefreshNotifier extends ChangeNotifier {
  AsyncValue<dynamic> _authState;

  _RouterRefreshNotifier(this._authState);

  AsyncValue<dynamic> get authState => _authState;

  void update(AsyncValue<dynamic> next) {
    _authState = next;
    notifyListeners();
  }
}
