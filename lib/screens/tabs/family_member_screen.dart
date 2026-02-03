import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/family_provider.dart';
import '../../theme/app_spacing.dart';

class FamilyMemberScreen extends ConsumerWidget {
  final String memberId;

  const FamilyMemberScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersState = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Member Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/family'),
        ),
      ),
      body: membersState.when(
        data: (members) {
          final member =
              members.where((m) => m.memberId == memberId).firstOrNull;
          if (member == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Member not found'),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.go('/family'),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Text('👤', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          member.name,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          member.relation,
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (member.email != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            member.email!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 13),
                          ),
                        ],
                        if (member.phone != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            member.phone!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'ID: ${member.memberId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 Health Records',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              'No health records yet',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
