import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

final _healthTips = [
  HealthTip(
    id: '1',
    category: 'nutrition',
    title: 'Stay Hydrated',
    description:
        'Drink at least 8 glasses of water daily to maintain optimal health and energy levels.',
    icon: '💧', // water_drop icon
  ),
  HealthTip(
    id: '2',
    category: 'exercise',
    title: 'Daily Movement',
    description:
        'Aim for 30 minutes of moderate exercise to boost your cardiovascular health.',
    icon: '🏃', // directions_run icon
  ),
  HealthTip(
    id: '3',
    category: 'mental',
    title: 'Mindful Breathing',
    description:
        'Practice deep breathing for 5 minutes to reduce stress and improve focus.',
    icon: '🧘', // self_improvement icon
  ),
  HealthTip(
    id: '4',
    category: 'general',
    title: 'Quality Sleep',
    description:
        'Get 7-8 hours of sleep each night for better immune function and mental clarity.',
    icon: '😴', // bed_time icon
  ),
  HealthTip(
    id: '5',
    category: 'nutrition',
    title: 'Balanced Diet',
    description:
        'Include fruits, vegetables, proteins, and whole grains in your daily meals.',
    icon: '🥗', // restaurant icon
  ),
];

class HealthTip {
  final String id;
  final String category;
  final String title;
  final String description;
  final String icon;

  HealthTip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class HealthTips extends StatelessWidget {
  const HealthTips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Health Tips',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Daily wellness advice',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _healthTips.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final tip = _healthTips[index];
              final categoryColor = _getCategoryColor(tip.category);

              return SizedBox(
                width: 280,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tip.icon,
                                style: const TextStyle(fontSize: 32)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                              ),
                              child: Text(
                                tip.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          tip.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: Text(
                            tip.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'nutrition':
        return AppColors.success;
      case 'exercise':
        return AppColors.secondary;
      case 'mental':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }
}
