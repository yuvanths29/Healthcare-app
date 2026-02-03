import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/appointments_list.dart';
import '../../widgets/health_tips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final session = authState.value;
    final familyState = ref.watch(familyMembersProvider);
    final familyCount = familyState.maybeWhen(
      data: (members) => members.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Header
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.go('/profile'),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              session?.name ?? 'User',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              session?.email ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              session?.userId ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite,
                              size: 16, color: AppColors.success),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Healthy',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Stats
                    Row(
                      children: [
                        _StatCard(
                            icon: Icons.bar_chart,
                            value: '0',
                            label: 'Reports'),
                        const SizedBox(width: AppSpacing.md),
                        _StatCard(
                            icon: Icons.people,
                            value: '$familyCount',
                            label: 'Family'),
                        const SizedBox(width: AppSpacing.md),
                        _StatCard(
                            icon: Icons.calendar_today,
                            value: '2',
                            label: 'Upcoming'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Profile completion
                    const SizedBox(height: AppSpacing.md),
                    _ProfileCompletion(ref: ref),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _QuickActionCard(
                      icon: Icons.science,
                      title: 'Scan Report',
                      description: 'Upload or scan lab results',
                      color: AppColors.primary,
                      onPressed: () => context.go('/scan'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionCard(
                      icon: Icons.groups,
                      title: 'Family Tree',
                      description: 'Manage family members',
                      color: AppColors.secondary,
                      onPressed: () => context.go('/family'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionCard(
                      icon: Icons.medication,
                      title: 'Medications',
                      description: 'Track your prescriptions',
                      color: AppColors.warning,
                      onPressed: () {},
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionCard(
                      icon: Icons.trending_up,
                      title: 'Health Trends',
                      description: 'View health analytics',
                      color: AppColors.info,
                      onPressed: () {},
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Health Tips
                    const HealthTips(),
                    const SizedBox(height: AppSpacing.xxl),

                    // Appointments
                    const AppointmentsList(),
                    const SizedBox(height: AppSpacing.xxl),

                    // Health Metrics
                    Text(
                      'Health Metrics',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _HealthMetricsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthMetricsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Text('📊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Track Your Health',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Monitor blood pressure, glucose, weight, and more vital signs over time.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompletion extends StatelessWidget {
  final WidgetRef ref;

  const _ProfileCompletion({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(healthProfileProvider);

    return profileState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        final fields = [
          profile.height,
          profile.weight,
          profile.allergies,
          profile.medicalConditions,
        ];
        final filled =
            fields.where((f) => f != null && f.trim().isNotEmpty).length;
        final percent = (filled / fields.length * 100).round();

        if (percent >= 100) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$percent% of your profile is completed',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Please complete the profile for enhanced app experience',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: filled / fields.length,
                            backgroundColor:
                                theme.dividerColor.withOpacity(0.2),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => context.go('/profile'),
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '→',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(icon, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
