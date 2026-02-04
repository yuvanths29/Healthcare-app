import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  static const List<String> _categories = [
    'Cardiology report',
    'Diabetics report',
    'Pregnancy report',
    'Blood pressure report',
    'ECG reports',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authProvider).value;

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
                      style:
                          theme.textTheme.displayLarge?.copyWith(fontSize: 32),
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          alignment: Alignment.center,
                          child:
                              const Text('📸', style: TextStyle(fontSize: 40)),
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
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () async {
                            final ok = await _ensurePermission(
                              context,
                              Permission.camera,
                              title: 'Allow Camera',
                              description:
                                  'To scan reports, please allow camera access.',
                            );
                            if (!ok || !context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Camera permission granted. Implement camera scan next.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Start Scan'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening file picker...'),
                                duration: Duration(milliseconds: 900),
                              ),
                            );

                            if (kIsWeb) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'File storage is not supported on Web in this build. Please run on Android/Desktop.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (session == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please login to upload reports.'),
                                ),
                              );
                              return;
                            }

                            FilePickerResult? picked;
                            try {
                              picked = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                withData: false,
                                dialogTitle: 'Select report to upload',
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Unable to open file picker: $e'),
                                ),
                              );
                              return;
                            }

                            if (!context.mounted) return;
                            final files = picked?.files;
                            if (files == null || files.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No file selected.'),
                                ),
                              );
                              return;
                            }
                            final file = files.first;
                            final path = file.path;
                            if (path == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Selected file path is unavailable on this platform.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final category = await _pickCategory(context);
                            if (!context.mounted) return;
                            if (category == null) return;

                            try {
                              await ref
                                  .read(
                                      reportsProvider(session.userId).notifier)
                                  .addReport(
                                    category: category,
                                    sourcePath: path,
                                    originalName: file.name,
                                  );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Saved to $category'),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Upload failed: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text('Upload File'),
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
                          width: (MediaQuery.of(context).size.width -
                                  AppSpacing.xl * 2 -
                                  AppSpacing.md) /
                              2,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Text(feature.$1,
                                      style: const TextStyle(fontSize: 32)),
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
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(fontSize: 11),
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
                          description:
                              'Take a photo or upload a PDF of your lab report',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StepItem(
                          number: '2',
                          color: AppColors.secondary,
                          title: 'AI Analysis',
                          description:
                              'Our AI extracts key metrics and values from your report',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StepItem(
                          number: '3',
                          color: AppColors.success,
                          title: 'Track & Monitor',
                          description:
                              'View trends, share with family, and get health insights',
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
                        Text('All Scans', style: theme.textTheme.titleMedium),
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
                    if (session == null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: Column(
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Login required',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Login to view and manage your uploaded reports.',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _ReportsSection(
                        userId: session.userId,
                        categories: _categories,
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

  static Future<String?> _pickCategory(BuildContext context) async {
    String? selected = _categories.first;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select category'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                initialValue: selected,
                items: _categories
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selected = v),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _ensurePermission(
    BuildContext context,
    Permission permission, {
    required String title,
    required String description,
  }) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    final requested = await permission.request();
    if (requested.isGranted) return true;

    if (requested.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission required'),
          content: const Text(
            'This permission is disabled. Please enable it from Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (open == true) {
        await openAppSettings();
      }
    }

    return false;
  }
}

class _ReportsSection extends ConsumerStatefulWidget {
  final String userId;
  final List<String> categories;

  const _ReportsSection({
    required this.userId,
    required this.categories,
  });

  @override
  ConsumerState<_ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends ConsumerState<_ReportsSection> {
  String _search = '';
  String? _selectedCategory;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsState = ref.watch(reportsProvider(widget.userId));

    return reportsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Unable to load reports: $e',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
      data: (reports) {
        final Map<String, List<ReportItem>> byCategory = {
          for (final c in widget.categories) c: <ReportItem>[]
        };
        for (final r in reports) {
          byCategory.putIfAbsent(r.category, () => <ReportItem>[]).add(r);
        }

        final filteredCategories = widget.categories
            .where((c) => c.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _search = '';
                                    _controller.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_selectedCategory == null) ...[
                      if (filteredCategories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'No categories match your search.',
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredCategories.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final c = filteredCategories[index];
                              final count = byCategory[c]?.length ?? 0;
                              return ListTile(
                                title: Text(c),
                                subtitle: Text('$count file(s)'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    setState(() => _selectedCategory = c),
                              );
                            },
                          ),
                        ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategory!,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = null;
                              _controller.clear();
                              _search = '';
                            }),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_selectedCategory == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'Select a category above to view reports for that category.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              )
            else
              Builder(builder: (context) {
                final items =
                    byCategory[_selectedCategory!] ?? const <ReportItem>[];
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No reports in this category yet.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: items
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                r.originalName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                        r.createdAtMs)
                                    .toLocal()
                                    .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () async {
                                try {
                                  await OpenFilex.open(r.storedPath);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Unable to open file: $e')),
                                  );
                                }
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await ref
                                      .read(reportsProvider(widget.userId)
                                          .notifier)
                                      .deleteReport(r.id);
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
          ],
        );
      },
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
            color: color.withValues(alpha: 0.2),
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
