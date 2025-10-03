import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/page_layout.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bool _isOwnProfile = true;

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

              const SizedBox(height: 16),

              // Add Photocard Button
              _buildAddPhotocardButton(),

              const SizedBox(height: 16),

              // Favorites Section
              _buildFavoritesSection(),

              const SizedBox(height: 16),

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
              onTap: () {
                context.go('/owned-cards');
              },
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
              onTap: () {
                context.go('/wishlist');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Favorites',
              value: '${profile?.favoritesCount ?? 0}',
              subtitle: 'starred',
              icon: Icons.star,
              color: AppTheme.mintAccent,
              onTap: () {
                context.go('/favorites');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotocardButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PrimaryButton(
        text: 'Add Photocard',
        icon: Icons.add_photo_alternate,
        onPressed: () {
          context.push('/add-photocard');
        },
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getCollectionPhotocards(status: 'favorites', limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomCard(
            color: AppTheme.white.withValues(alpha: 0.7),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return CustomCard(
            color: AppTheme.white.withValues(alpha: 0.7),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Failed to load favorites',
                style: TextStyle(color: AppTheme.darkGray),
              ),
            ),
          );
        }

        final data = snapshot.data;
        final photocards = data?['photocards'] as List<dynamic>? ?? [];

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 0),
          child: CustomCard(
            color: AppTheme.white.withValues(alpha: 0.7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favorite Cards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                if (photocards.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 48,
                            color: AppTheme.darkGray,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No favorite cards yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap the star on cards to add them here!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photocards.length,
                      itemBuilder: (context, index) {
                        final photocard = photocards[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PhotocardWidget(
                            imageUrl: photocard['image_url'],
                            groupName: photocard['group_name'],
                            memberName: photocard['member_stage_name'] ?? photocard['member_name'],
                            albumName: photocard['album_title'],
                            isOwned: photocard['is_owned'] ?? false,
                            isWishlisted: photocard['is_wishlisted'] ?? false,
                            isFavorite: photocard['is_favorite'] ?? false,
                            showActions: false, // Hide actions in profile view
                            useAspectRatio: false,
                            onTap: () {
                              context.push('/photocard/${photocard['id']}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_isOwnProfile) ...[
            Expanded(
              child: SecondaryButton(
                text: 'Owned',
                icon: Icons.check_circle,
                onPressed: () {
                  context.go('/owned-cards');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                text: 'Wishlist',
                icon: Icons.favorite,
                onPressed: () {
                  context.go('/wishlist');
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: SecondaryButton(
                text: 'View Cards',
                icon: Icons.photo_library,
                onPressed: () {
                  context.go('/owned-cards');
                },
              ),
            ),
          ],
        ],
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
              leading: const Icon(Icons.photo_library),
              title: const Text('My Collection'),
              onTap: () {
                Navigator.pop(context);
                context.go('/owned-cards');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate),
              title: const Text('Add Photocard'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-photocard');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.primaryPurple),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppTheme.error),
              title: const Text('Delete Account', style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                try {
                  // Logout using AuthProvider
                  await context.read<AuthProvider>().signOut();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: AppTheme.success,
                      ),
                    );

                    // Navigate to signup page
                    context.go('/signup');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete your account?'),
              SizedBox(height: 12),
              Text(
                'This will permanently delete:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• All your photocards'),
              Text('• Your collection data'),
              Text('• Your profile information'),
              Text('• All account data'),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Deleting account...'),
                      ],
                    ),
                  ),
                );

                try {
                  // Delete account
                  print('Starting account deletion...');
                  await ApiService.deleteAccount();
                  print('Account deletion successful');

                  // Close loading dialog
                  if (mounted) Navigator.of(context).pop();

                  // Logout user
                  print('Signing out user...');
                  await context.read<AuthProvider>().signOut();
                  print('User signed out successfully');

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: AppTheme.success,
                      ),
                    );

                    // Navigate to signup page
                    print('Navigating to signup page...');
                    context.go('/signup');
                  }
                } catch (e) {
                  print('Error during account deletion: $e');

                  // Close loading dialog if still open
                  if (mounted) {
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting account: $e'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
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


