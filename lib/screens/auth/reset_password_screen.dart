import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_storage.dart';
import '../../theme/app_spacing.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Reset your password',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                Text('Email', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(hintText: 'Enter your email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('New password', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'New password'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Confirm password', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmController,
                  decoration:
                      const InputDecoration(hintText: 'Confirm password'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onReset(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _loading ? null : _onReset,
                  child: Text(_loading ? 'Saving...' : 'Reset Password'),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to login'),
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
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final email = _emailController.text.trim();
    final pw = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || pw.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = 'Please fill all fields.';
        _loading = false;
      });
      return;
    }

    if (pw != confirm) {
      setState(() {
        _error = 'Passwords do not match.';
        _loading = false;
      });
      return;
    }

    if (pw.length < 6) {
      setState(() {
        _error = 'Password should be at least 6 characters.';
        _loading = false;
      });
      return;
    }

    final result =
        await AuthStorage.resetPassword(email: email, newPassword: pw);

    if (!mounted) return;

    if (!result.ok) {
      setState(() {
        _error = result.message;
        _loading = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _loading = false);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. You can now login.')),
    );

    context.go('/login');
  }
}
