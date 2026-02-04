import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class TabsScreen extends StatelessWidget {
  final Widget child;

  const TabsScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkBackgroundElevated
              : AppColors.lightBackgroundElevated,
          border: Border(
            top: BorderSide(
              color:
                  isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.favorite,
                  label: 'Dashboard',
                  isSelected: _getCurrentIndex(context) == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavBarItem(
                  icon: Icons.people,
                  label: 'Family',
                  isSelected: _getCurrentIndex(context) == 1,
                  onTap: () => context.go('/family'),
                ),
                _NavBarItem(
                  icon: Icons.science,
                  label: 'Scan',
                  isSelected: _getCurrentIndex(context) == 2,
                  onTap: () => context.go('/scan'),
                ),
                _NavBarItem(
                  icon: Icons.bloodtype,
                  label: 'Donate',
                  isSelected: _getCurrentIndex(context) == 3,
                  onTap: () => context.go('/donation'),
                ),
                _NavBarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _getCurrentIndex(context) == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/family')) return 1;
    if (location.startsWith('/scan')) return 2;
    if (location.startsWith('/donation')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 28 : 24,
              color: isSelected
                  ? AppColors.primary
                  : (theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
