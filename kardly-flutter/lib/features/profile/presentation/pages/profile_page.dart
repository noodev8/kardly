import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/page_layout.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isOwnProfile = true;

  @override
  void initState() {
    super.initState();
    // Load profile data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading && profileProvider.currentProfile == null) {
          return const Scaffold(
            backgroundColor: AppTheme.lightGray,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (profileProvider.error != null && profileProvider.currentProfile == null) {
          return Scaffold(
            backgroundColor: AppTheme.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${profileProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.charcoal),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: () {
                      profileProvider.loadProfile();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return PageLayout(
          title: profileProvider.currentProfile?.username ?? 'Profile',
          subtitle: profileProvider.currentProfile?.joinDate != null
              ? 'Joined ${_formatDate(profileProvider.currentProfile!.joinDate)}'
              : null,
          headerTrailing: _buildHeaderActions(),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Stats Section
              _buildStatsSection(profileProvider.currentProfile),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions() {
    return IconButton(
      icon: const Icon(
        Icons.more_vert,
        color: AppTheme.white,
        size: 24,
      ),
      onPressed: () {
        _showProfileMenu();
      },
    );
  }





  Widget _buildStatsSection(UserProfile? profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Photocards',
              value: '${profile?.photocardCount ?? 0}',
              subtitle: 'owned',
              icon: Icons.photo_library,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Wishlist',
              value: '${profile?.wishlistCount ?? 0}',
              subtitle: 'wanted',
              icon: Icons.favorite,
              color: AppTheme.accentPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Followers',
              value: '${profile?.followersCount ?? 0}',
              subtitle: 'following you',
              icon: Icons.people,
              color: AppTheme.mintAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_isOwnProfile) ...[
            Expanded(
              child: PrimaryButton(
                text: 'Edit Profile',
                icon: Icons.edit,
                onPressed: () {
                  // TODO: Navigate to edit profile
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                text: 'Share',
                icon: Icons.share,
                onPressed: () {
                  // TODO: Share profile
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: PrimaryButton(
                text: 'Follow',
                icon: Icons.person_add,
                onPressed: () {
                  // TODO: Follow user
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                text: 'Message',
                icon: Icons.message,
                onPressed: () {
                  // TODO: Message user
                },
              ),
            ),
          ],
        ],
      ),
    );
  }







  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report user
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block user
              },
            ),
          ],
        ),
      ),
    );
  }



  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to help
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement logout
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}


