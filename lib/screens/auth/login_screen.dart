import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Email / User ID',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter email or user id',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Password',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/reset-password'),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF14b8a6),
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _loading ? null : _onLogin,
                  child: Text(_loading ? 'Logging in...' : 'Login'),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Text('🔍', style: TextStyle(fontSize: 18)),
                        label: const Text('Google Sign In'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Text('✉️', style: TextStyle(fontSize: 18)),
                        label: const Text('Email Sign Up'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF14b8a6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final result = await ref.read(authProvider.notifier).login(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (!result.ok) {
        setState(() {
          _error = result.message;
          _loading = false;
        });
        return;
      }

      context.go('/home');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
