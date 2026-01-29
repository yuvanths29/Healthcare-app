import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final features = [
      ('🩺', 'CBC Reports', 'Complete blood count analysis'),
      ('💉', 'Lipid Profile', 'Cholesterol and triglycerides'),
      ('🔬', 'HbA1c', 'Diabetes monitoring'),
      ('🦴', 'Thyroid Tests', 'TSH, T3, T4 levels'),
      ('💊', 'Liver Function', 'SGPT, SGOT, bilirubin'),
      ('🫁', 'Kidney Function', 'Creatinine, urea, BUN'),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔬 Report Scanner',
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Scan medical reports using your camera and extract key health metrics automatically.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Scanner Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          alignment: Alignment.center,
                          child: const Text('📸', style: TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Camera Scanner',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Capture images of your lab reports for instant analysis and data extraction',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('📷 Start Scan'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('📁 Upload File'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Features Grid
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What We Can Extract',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'AI-powered extraction for common lab tests',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: features.map((feature) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - AppSpacing.xl * 2 - AppSpacing.md) / 2,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Text(feature.$1, style: const TextStyle(fontSize: 32)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    feature.$2,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    feature.$3,
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // How It Works
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📋 How It Works',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StepItem(
                          number: '1',
                          color: AppColors.primary,
                          title: 'Capture or Upload',
                          description: 'Take a photo or upload a PDF of your lab report',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StepItem(
                          number: '2',
                          color: AppColors.secondary,
                          title: 'AI Analysis',
                          description: 'Our AI extracts key metrics and values from your report',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StepItem(
                          number: '3',
                          color: AppColors.success,
                          title: 'Track & Monitor',
                          description: 'View trends, share with family, and get health insights',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Scan History
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Scans', style: theme.textTheme.titleMedium),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Column(
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No Scans Yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Start scanning your medical reports to build your health history',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
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
}

class _StepItem extends StatelessWidget {
  final String number;
  final Color color;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
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
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
