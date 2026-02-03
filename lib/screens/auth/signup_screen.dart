import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final password = _passwordController.text;
    final strength =
        password.isNotEmpty ? _getPasswordStrength(password) : null;

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
                  'Sign Up',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                const SizedBox(height: AppSpacing.md),
                Text('Name', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Email', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Mobile Number', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your mobile number',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Password', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Create a password',
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _onSignup(),
                ),
                if (strength != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Strength: ${strength.label}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          child: LinearProgressIndicator(
                            value: strength.score / 5,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              strength.label == 'Strong'
                                  ? AppColors.success
                                  : strength.label == 'Medium'
                                      ? AppColors.warning
                                      : AppColors.danger,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use 8+ chars, upper/lowercase, a number, and a symbol.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _loading ? null : _onSignup,
                  child: Text(_loading ? 'Saving...' : 'Create Account'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/join-family'),
                  child: const Text('Join Existing Family'),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Google Sign Up'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.mail_outline),
                        label: const Text('Email Sign Up'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Already have an account? Login',
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
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ({int score, String label}) _getPasswordStrength(String password) {
    final lengthOk = password.length >= 8;
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[^A-Za-z0-9]'));

    final score = [lengthOk, hasLower, hasUpper, hasNumber, hasSpecial]
        .where((x) => x)
        .length;

    String label = 'Weak';
    if (score >= 4) {
      label = 'Strong';
    } else if (score >= 3) {
      label = 'Medium';
    }

    return (score: score, label: label);
  }

  Future<void> _onSignup() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final mobile = _mobileController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Please fill all fields.';
          _loading = false;
        });
        return;
      }

      if (!email.contains('@')) {
        setState(() {
          _error = 'Please enter a valid email.';
          _loading = false;
        });
        return;
      }

      if (!RegExp(r'^\d{10,15}$').hasMatch(mobile)) {
        setState(() {
          _error = 'Please enter a valid mobile number.';
          _loading = false;
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          _error = 'Password should be at least 6 characters.';
          _loading = false;
        });
        return;
      }

      final result = await ref.read(authProvider.notifier).signUp(
            name: name,
            email: email,
            mobile: mobile,
            password: password,
          );

      if (!mounted) return;

      if (!result.ok) {
        setState(() {
          _error = result.message;
          _loading = false;
        });
        return;
      }

      context.go('/permissions');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
