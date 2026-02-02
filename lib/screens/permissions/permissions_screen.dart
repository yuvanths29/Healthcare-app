import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_spacing.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  static const _completedKey = 'onboarding.permissions.completed.v1';

  bool _loading = true;
  String? _error;
  bool _cameraGranted = false;
  bool _filesGranted = false;
  bool _contactsGranted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Help us set up your experience',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We use these permissions for scanning reports, uploading documents, and managing family profiles.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _PermissionTile(
                      title: 'Camera',
                      subtitle: 'Scan prescriptions and medical documents',
                      icon: Icons.photo_camera_outlined,
                      granted: _cameraGranted,
                      onPressed: _requestCamera,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PermissionTile(
                      title: 'Photos / Files',
                      subtitle: 'Upload reports from your device',
                      icon: Icons.folder_outlined,
                      granted: _filesGranted,
                      onPressed: _requestFiles,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PermissionTile(
                      title: 'Contacts',
                      subtitle: 'Add family members quickly',
                      icon: Icons.contacts_outlined,
                      granted: _contactsGranted,
                      onPressed: _requestContacts,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: _onContinue,
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _onContinue,
                      child: const Text('Not now'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Permission _filesPermission() {
    // Prefer platform-appropriate permission for media/files.
    // - iOS: photos
    // - Android: we may need photos (Android 13+) OR storage (older Android)
    return Platform.isIOS ? Permission.photos : Permission.photos;
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_completedKey) ?? false;

      if (!mounted) return;

      if (completed) {
        context.go('/home');
        return;
      }

      await _refreshStatuses();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load permissions. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);

    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _refreshStatuses() async {
    try {
      final camera = await Permission.camera.status;
      final contacts = await Permission.contacts.status;

      final filesPrimary = await _filesPermission().status;
      final PermissionStatus filesFallback = Platform.isAndroid
          ? await Permission.storage.status
          : PermissionStatus.denied;

      if (!mounted) return;

      setState(() {
        _cameraGranted = camera.isGranted;
        _contactsGranted = contacts.isGranted;
        _filesGranted = filesPrimary.isGranted || filesFallback.isGranted;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Permissions are not available on this device right now.';
      });
    }
  }

  Future<void> _requestCamera() async {
    await Permission.camera.request();
    await _refreshStatuses();
  }

  Future<void> _requestContacts() async {
    await Permission.contacts.request();
    await _refreshStatuses();
  }

  Future<void> _requestFiles() async {
    // Try photos permission first (Android 13+ / iOS). Fallback to storage for older Android.
    final primary = await _filesPermission().request();
    if (Platform.isAndroid && !primary.isGranted) {
      await Permission.storage.request();
    }
    await _refreshStatuses();
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;

  final String subtitle;
  final IconData icon;
  final bool granted;
  final VoidCallback onPressed;
  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.granted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            granted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : OutlinedButton(
                    onPressed: onPressed,
                    child: const Text('Allow'),
                  ),
          ],
        ),
      ),
    );
  }
}
