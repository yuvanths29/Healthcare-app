import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/family_member.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersState = ref.watch(familyMembersProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👨‍👩‍👧‍👦 Family Tree',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add family members, view their profile and health reports.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Add Member Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '➕ Add New Member',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Full name',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _relationController,
                        decoration: const InputDecoration(
                          hintText: 'Relation (e.g., Mother, Father, Spouse)',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email Address (optional)',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _addMember,
                        child: const Text('Add Member'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Members List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family Members',
                    style: theme.textTheme.titleMedium,
                  ),
                  membersState.when(
                    data: (members) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '${members.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Members List
              membersState.when(
                data: (members) {
                  if (members.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Column(
                          children: [
                            const Text('👨‍👩‍👧‍👦',
                                style: TextStyle(fontSize: 64)),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No Family Members Yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Add your first family member to start building your family health tree',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: members.map((member) {
                      final isSelected = member.memberId == _selectedId;
                      final avatarColor = _getAvatarColor(member.name);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.dividerTheme.color!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setState(() {
                              _selectedId = isSelected ? null : member.memberId;
                            }),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: avatarColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusFull),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          member.name[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: avatarColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.name,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.xs),
                                            Text(
                                              member.relation,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.xs),
                                            Row(
                                              children: [
                                                Text(
                                                  'ID:',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: AppSpacing.xs),
                                                Text(
                                                  member.memberId,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _handleDeleteMember(
                                          context,
                                          members,
                                          member,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.danger,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                        ),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    const Divider(),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Quick Actions',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                  '/family-member/${member.memberId}');
                                            },
                                            icon: const Text('👤',
                                                style: TextStyle(fontSize: 16)),
                                            label: const Text(
                                              'View Profile',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                context.go('/scan'),
                                            icon: const Text('🔬',
                                                style: TextStyle(fontSize: 16)),
                                            label: const Text(
                                              'View Reports',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Footer Hint
              Center(
                child: Text(
                  _selectedId != null
                      ? '✨ Selected: ${membersState.maybeWhen(data: (m) => m.firstWhere((x) => x.memberId == _selectedId).name, orElse: () => '')}'
                      : '💡 Tip: Tap a member to view profile & reports',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMember() async {
    if (_nameController.text.trim().isEmpty ||
        _relationController.text.trim().isEmpty) {
      return;
    }

    try {
      final authState = ref.read(authProvider);
      final loggedInMemberId = authState.value?.memberId;

      await ref.read(familyMembersProvider.notifier).addMember(
            name: _nameController.text.trim(),
            relation: _relationController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            loggedInMemberId: loggedInMemberId,
          );

      _nameController.clear();
      _relationController.clear();
      _emailController.clear();
      _phoneController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Color _getAvatarColor(String name) {
    final index = name.isNotEmpty
        ? name.codeUnitAt(0) % AppColors.avatarColors.length
        : 0;
    return AppColors.avatarColors[index];
  }

  Future<void> _handleDeleteMember(
    BuildContext context,
    List<FamilyMember> allMembers,
    FamilyMember memberToDelete,
  ) async {
    final authState = ref.read(authProvider);
    final loggedInMemberId = authState.value?.memberId;

    if (loggedInMemberId == memberToDelete.memberId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You cannot delete your own profile while logged in. Please log out first if you want to delete your account.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final hasChildren = allMembers.any(
        (m) => m.parentId != null && m.parentId == memberToDelete.memberId);

    if (hasChildren) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This member has children. Remove or reassign them first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final String confirmMessage = memberToDelete.hasAccount
        ? 'This member has an active account. Deleting will remove their access. Are you sure?'
        : 'Are you sure you want to delete this family member?';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.read(familyMembersProvider.notifier).removeMember(
              memberToDelete.memberId,
              loggedInMemberId: loggedInMemberId,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      }
    }
  }
}
