import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading && profileProvider.currentProfile == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (profileProvider.error != null && profileProvider.currentProfile == null) {
              return Center(
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
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(profileProvider.currentProfile),

                  // Stats Section
                  _buildStatsSection(profileProvider.currentProfile),

                  // Action Buttons
                  _buildActionButtons(),

                  // Settings (if own profile)
                  if (_isOwnProfile) _buildSettingsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.white.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.white,
                    ),
                  ),
                  if (_isOwnProfile)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile?.username ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (profile?.isPremium == true) const PremiumBadge(isSmall: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.bio ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.white,
                      ),
                    ),

                  ],
                ),
              ),
              if (!_isOwnProfile)
                IconButtonCustom(
                  icon: Icons.more_vert,
                  onPressed: () {
                    _showProfileOptions();
                  },
                  backgroundColor: AppTheme.white.withValues(alpha: 0.2),
                  iconColor: AppTheme.white,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Join Date and Location
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Joined ${_formatJoinDate(profile?.joinDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.white,
              ),
              const SizedBox(width: 4),
              Text(
                profile?.location ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ],
      ),
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





  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy',
                  subtitle: 'Control who can see your profile',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsItem(
                  icon: Icons.star,
                  title: 'Upgrade to Premium',
                  subtitle: 'Unlock all features',
                  onTap: () {},
                  trailing: const PremiumBadge(isSmall: true),
                ),
                const Divider(height: 1),
                _SettingsItem(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help with the app',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () {},
                  textColor: AppTheme.error,
                ),
              ],
            ),
          ),
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

  String _formatJoinDate(DateTime? joinDate) {
    if (joinDate == null) return 'Unknown';

    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[joinDate.month - 1]} ${joinDate.year}';
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppTheme.primaryPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.charcoal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.darkGray,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: AppTheme.darkGray,
      ),
      onTap: onTap,
    );
  }
}
