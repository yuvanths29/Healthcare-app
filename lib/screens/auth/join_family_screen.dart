import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/family_member.dart';
import '../../providers/account_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _phoneEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  FamilyMember? _foundMember;
  bool _showPasswordForm = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Existing Family'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/signup'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '👨‍👩‍👧‍👦 Join Your Family',
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Enter the phone number or email associated with your family member profile.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_foundMember == null) ...[
                          TextField(
                            controller: _phoneEmailController,
                            enabled: !_isLoading && !_showPasswordForm,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number or Email',
                              hintText: 'e.g., +1234567890 or name@example.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _lookupMember,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Search'),
                          ),
                        ] else if (!_showPasswordForm) ...[
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  '✅ Member Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _foundMember!.name,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _foundMember!.relation,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: _reset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            child: const Text('Search Again'),
                          ),
                        ] else ...[
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  '🔐 Create Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Set a password for ${_foundMember!.name}',
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'At least 6 characters',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _createAccount,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create Account'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: _reset,
                            child: const Text('Back'),
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusLg),
                              border: Border.all(color: AppColors.danger),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Back to Sign Up'),
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
    _phoneEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (_foundMember == null) return;

    setState(() => _isLoading = true);

    final result =
        await ref.read(accountProvider.notifier).createAccountForMember(
              memberId: _foundMember!.memberId,
              emailOrPhone: _phoneEmailController.text.trim(),
              password: password,
            );

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! You can now log in.'),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.go('/login');
      });
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  Future<void> _lookupMember() async {
    final input = _phoneEmailController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter phone number or email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final member =
        await ref.read(accountProvider.notifier).lookupFamilyMember(input);

    setState(() {
      _isLoading = false;
      _foundMember = member;

      if (member == null) {
        _errorMessage = 'No family profile found with that phone or email';
      } else if (member.hasAccount) {
        _errorMessage = 'Account already created for this member';
      } else {
        _showPasswordForm = true;
        _errorMessage = null;
      }
    });
  }

  void _reset() {
    setState(() {
      _foundMember = null;
      _showPasswordForm = false;
      _errorMessage = null;
      _passwordController.clear();
    });
  }
}
