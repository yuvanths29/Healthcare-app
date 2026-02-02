import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/health_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicalConditionsController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _allergiesController = TextEditingController();
    _medicalConditionsController = TextEditingController();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  void _showHealthProfileModal(HealthProfile? currentProfile) {
    if (currentProfile != null) {
      _heightController.text = currentProfile.height ?? '';
      _weightController.text = currentProfile.weight ?? '';
      _allergiesController.text = currentProfile.allergies ?? '';
      _medicalConditionsController.text =
          currentProfile.medicalConditions ?? '';
    } else {
      _heightController.clear();
      _weightController.clear();
      _allergiesController.clear();
      _medicalConditionsController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💚 Update Health Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'e.g., 175',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 70',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  hintText: 'e.g., Peanuts, Penicillin',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _medicalConditionsController,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions',
                  hintText: 'e.g., Diabetes, Hypertension',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = HealthProfile(
                height: _heightController.text.isNotEmpty
                    ? _heightController.text
                    : null,
                weight: _weightController.text.isNotEmpty
                    ? _weightController.text
                    : null,
                allergies: _allergiesController.text.isNotEmpty
                    ? _allergiesController.text
                    : null,
                medicalConditions: _medicalConditionsController.text.isNotEmpty
                    ? _medicalConditionsController.text
                    : null,
              );
              ref.read(healthProfileProvider.notifier).updateProfile(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final session = authState.value;
    final themeMode = ref.watch(themeModeProvider);
    final healthState = ref.watch(healthProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerTheme.color!,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxxl + 8,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(session?.name),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      session?.name ?? 'User',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      session?.email ?? 'No email',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Account Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Account Information',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _InfoRow(
                              label: 'Full Name',
                              value: session?.name ?? '-',
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'User ID',
                              value: session?.userId ?? '-',
                              valueStyle: const TextStyle(fontSize: 12),
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Email',
                              value: session?.email ?? '-',
                              valueStyle: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Appearance
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.palette, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Appearance',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Switch between light and dark theme for comfortable viewing',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(themeModeProvider.notifier)
                                    .toggleTheme();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    themeMode == ThemeMode.dark ? '🌙' : '☀️',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Text(
                                    themeMode == ThemeMode.dark
                                        ? 'Dark Mode'
                                        : 'Light Mode',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Health Profile
                    GestureDetector(
                      onTap: () {
                        healthState.whenData((profile) {
                          _showHealthProfileModal(profile);
                        });
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '💚 Health Profile',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Track height, weight, allergies, medical conditions, and more',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              healthState.when(
                                data: (profile) {
                                  if (profile.height == null &&
                                      profile.weight == null &&
                                      profile.allergies == null &&
                                      profile.medicalConditions == null) {
                                    return Center(
                                      child: Text(
                                        'Click to add your health information',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (profile.height != null) ...[
                                        _HealthInfoItem(
                                            icon: '📏',
                                            label: 'Height',
                                            value: '${profile.height} cm'),
                                        const SizedBox(height: AppSpacing.md),
                                      ],
                                      if (profile.weight != null) ...[
                                        _HealthInfoItem(
                                            icon: '⚖️',
                                            label: 'Weight',
                                            value: '${profile.weight} kg'),
                                        const SizedBox(height: AppSpacing.md),
                                      ],
                                      if (profile.allergies != null) ...[
                                        _HealthInfoItem(
                                            icon: '⚠️',
                                            label: 'Allergies',
                                            value: profile.allergies!),
                                        const SizedBox(height: AppSpacing.md),
                                      ],
                                      if (profile.medicalConditions != null)
                                        _HealthInfoItem(
                                            icon: '🩺',
                                            label: 'Medical Conditions',
                                            value: profile.medicalConditions!),
                                    ],
                                  );
                                },
                                loading: () => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                error: (error, stack) => Center(
                                  child: Text('Error: $error'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // App Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ℹ️ About',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _InfoRow(label: 'Version', value: '1.0.0'),
                            const Divider(),
                            _InfoRow(label: 'Build', value: 'Healthcare App'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Logout Button
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      child: const Text('🚪 Logout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('')
        .toUpperCase()
        .substring(0, name.split(' ').length >= 2 ? 2 : 1);
  }
}

class _HealthInfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _HealthInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: valueStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
