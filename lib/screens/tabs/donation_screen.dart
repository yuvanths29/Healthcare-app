import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class BloodRequest {
  final String id;
  final String personName;
  final String bloodType;
  final int unitsNeeded;
  final String urgency;
  final String location;
  final String contact;
  final String reason;
  final int patientAge;
  final bool isActive;

  BloodRequest({
    required this.id,
    required this.personName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.urgency,
    required this.location,
    required this.contact,
    required this.reason,
    required this.patientAge,
    required this.isActive,
  });
}

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _BloodRequestCard extends StatelessWidget {
  final BloodRequest request;

  const _BloodRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.bloodtype,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.personName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Age: ${request.patientAge} • ${request.location}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(request.urgency).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  request.urgency,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getUrgencyColor(request.urgency),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.bloodtype,
                  label: 'Blood Type',
                  value: request.bloodType,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoChip(
                  icon: Icons.inventory_2,
                  label: 'Units Needed',
                  value: '${request.unitsNeeded}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Reason: ${request.reason}',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showContactDialog(context, request);
              },
              icon: const Icon(Icons.phone),
              label: const Text('Offer to Donate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Critical':
        return Colors.red;
      case 'Urgent':
        return Colors.orange;
      case 'Moderate':
        return Colors.yellow[700] ?? Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _showContactDialog(BuildContext context, BloodRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact to Donate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.personName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Phone: ${request.contact}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Blood Type Needed: ${request.bloodType}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Units Needed: ${request.unitsNeeded}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Location: ${request.location}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Call ${request.personName} at ${request.contact} to help',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationScreenState extends State<DonationScreen> {
  // Sample blood requests data from individuals
  final List<BloodRequest> bloodRequests = [
    BloodRequest(
      id: '1',
      personName: 'John Smith',
      bloodType: 'O+',
      unitsNeeded: 2,
      urgency: 'Critical',
      location: 'Downtown Hospital',
      contact: '+1-555-0101',
      reason: 'Emergency surgery required',
      patientAge: 45,
      isActive: true,
    ),
    BloodRequest(
      id: '2',
      personName: 'Sarah Johnson',
      bloodType: 'A+',
      unitsNeeded: 1,
      urgency: 'Urgent',
      location: 'St. Mary\'s Hospital',
      contact: '+1-555-0102',
      reason: 'Post-operative transfusion needed',
      patientAge: 32,
      isActive: true,
    ),
    BloodRequest(
      id: '3',
      personName: 'Michael Brown',
      bloodType: 'B-',
      unitsNeeded: 3,
      urgency: 'Moderate',
      location: 'General Hospital',
      contact: '+1-555-0103',
      reason: 'Treatment for chronic condition',
      patientAge: 58,
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkBackgroundElevated
            : AppColors.lightBackgroundElevated,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: Text(
                              'Help Save Lives',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'People in your community need blood. If you\'re eligible and willing to donate, connect with those in need.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Active Blood Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final request = bloodRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _BloodRequestCard(request: request),
                  );
                },
                childCount: bloodRequests.length,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackgroundElevated
            : AppColors.lightBackgroundElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
