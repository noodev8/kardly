import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 24),
              

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 24),
              
              // Trending Photocards
              _buildTrendingSection(),
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back! 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.charcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover new photocards and manage your collection',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
        ),
        IconButtonCustom(
          icon: Icons.notifications_outlined,
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
      ],
    );
  }



  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.search,
                title: 'Search Cards',
                subtitle: 'Find photocards',
                color: AppTheme.primaryPurple,
                onTap: () {
                  context.go('/search');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.photo_library,
                title: 'My Collection',
                subtitle: 'View your cards',
                color: AppTheme.accentPink,
                onTap: () {
                  context.go('/collection');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.swap_horiz,
                title: 'Trading Hub',
                subtitle: 'Trade with others',
                color: AppTheme.mintAccent,
                onTap: () {
                  context.go('/trading');
                },
                isPremium: true,
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Trending Photocards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoal,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Navigate to trending page
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190, // Increased height to accommodate new layout
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 130, // Reduced width to fit better
                margin: const EdgeInsets.only(right: 12),
                child: PhotocardWidget(
                  groupName: _mockGroups[index % _mockGroups.length],
                  memberName: _mockMembers[index % _mockMembers.length],
                  albumName: _mockAlbums[index % _mockAlbums.length],
                  rarity: _mockRarities[index % _mockRarities.length],
                  useAspectRatio: false, // Don't use aspect ratio in horizontal list
                  onTap: () {
                    context.push('/photocard/$index');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
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
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: CustomCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User${index + 1} added NewJeans Haerin to wishlist',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${index + 1} hour${index == 0 ? '' : 's'} ago',
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
    );
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPremium;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              if (isPremium) const PremiumBadge(isSmall: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
