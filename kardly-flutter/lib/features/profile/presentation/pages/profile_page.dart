import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isOwnProfile = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              // Stats Section
              _buildStatsSection(),
              
              // Action Buttons
              _buildActionButtons(),
              
              // Collection Preview
              _buildCollectionPreview(),
              
              // Recent Activity
              _buildRecentActivity(),
              
              // Settings (if own profile)
              if (_isOwnProfile) _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                    backgroundColor: AppTheme.white.withOpacity(0.3),
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
                        const Text(
                          'KpopFan2024',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const PremiumBadge(isSmall: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'NewJeans & BLACKPINK collector',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Trader Rating
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: 4.8,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppTheme.warning,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '4.8 (24 trades)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
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
                  backgroundColor: AppTheme.white.withOpacity(0.2),
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
              const Text(
                'Joined March 2024',
                style: TextStyle(
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
              const Text(
                'London, UK',
                style: TextStyle(
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

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Photocards',
              value: '127',
              subtitle: 'owned',
              icon: Icons.photo_library,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Wishlist',
              value: '43',
              subtitle: 'wanted',
              icon: Icons.favorite,
              color: AppTheme.accentPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Followers',
              value: '89',
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

  Widget _buildCollectionPreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Collection Highlights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full collection
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: PhotocardWidget(
                    groupName: _mockGroups[index % _mockGroups.length],
                    memberName: _mockMembers[index % _mockMembers.length],
                    albumName: _mockAlbums[index % _mockAlbums.length],
                    rarity: _mockRarities[index % _mockRarities.length],
                    isOwned: true,
                    showActions: false,
                    onTap: () {
                      // TODO: Navigate to photocard detail
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getActivityColor(index).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getActivityIcon(index),
                        color: _getActivityColor(index),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getActivityText(index),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${index + 1} day${index == 0 ? '' : 's'} ago',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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

  Color _getActivityColor(int index) {
    switch (index % 4) {
      case 0:
        return AppTheme.success;
      case 1:
        return AppTheme.accentPink;
      case 2:
        return AppTheme.primaryPurple;
      case 3:
        return AppTheme.warning;
      default:
        return AppTheme.primaryPurple;
    }
  }

  IconData _getActivityIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.add_circle;
      case 1:
        return Icons.favorite;
      case 2:
        return Icons.swap_horiz;
      case 3:
        return Icons.star;
      default:
        return Icons.add_circle;
    }
  }

  String _getActivityText(int index) {
    switch (index % 4) {
      case 0:
        return 'Added NewJeans Haerin to collection';
      case 1:
        return 'Added BLACKPINK Jennie to wishlist';
      case 2:
        return 'Completed trade with User123';
      case 3:
        return 'Received 5-star rating from trader';
      default:
        return 'Recent activity';
    }
  }

  // Mock data
  static const List<String> _mockGroups = [
    'NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY'
  ];
  
  static const List<String> _mockMembers = [
    'Minji', 'Hanni', 'Danielle', 'Haerin', 'Hyein'
  ];
  
  static const List<String> _mockAlbums = [
    'Get Up', 'NewJeans', 'OMG', 'Ditto', 'Hurt'
  ];
  
  static const List<String> _mockRarities = [
    'Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'
  ];
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
