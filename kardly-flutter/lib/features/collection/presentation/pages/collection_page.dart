import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedView = 'grid';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Stats Cards
            _buildStatsSection(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOwnedTab(),
                  _buildWishlistTab(),
                  _buildAlbumsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Collection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your photocards and wishlist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButtonCustom(
                icon: _selectedView == 'grid' ? Icons.grid_view : Icons.grid_view_outlined,
                onPressed: () {
                  setState(() {
                    _selectedView = 'grid';
                  });
                },
                backgroundColor: _selectedView == 'grid' 
                    ? AppTheme.primaryPurple 
                    : AppTheme.lightPurple.withOpacity(0.3),
                iconColor: _selectedView == 'grid' 
                    ? AppTheme.white 
                    : AppTheme.primaryPurple,
                size: 40,
              ),
              const SizedBox(width: 8),
              IconButtonCustom(
                icon: _selectedView == 'album' ? Icons.photo_album : Icons.photo_album_outlined,
                onPressed: () {
                  setState(() {
                    _selectedView = 'album';
                  });
                },
                backgroundColor: _selectedView == 'album' 
                    ? AppTheme.primaryPurple 
                    : AppTheme.lightPurple.withOpacity(0.3),
                iconColor: _selectedView == 'album' 
                    ? AppTheme.white 
                    : AppTheme.primaryPurple,
                size: 40,
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
              title: 'Owned',
              value: '47',
              subtitle: 'photocards',
              color: AppTheme.success,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Wishlist',
              value: '23',
              subtitle: 'wanted',
              color: AppTheme.accentPink,
              icon: Icons.favorite,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Value',
              value: '£340',
              subtitle: 'estimated',
              color: AppTheme.warning,
              icon: Icons.trending_up,
              isPremium: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryPurple,
        unselectedLabelColor: AppTheme.darkGray,
        indicatorColor: AppTheme.primaryPurple,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Owned'),
          Tab(text: 'Wishlist'),
          Tab(text: 'Albums'),
        ],
      ),
    );
  }

  Widget _buildOwnedTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              const Text(
                '47 photocards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const Spacer(),
              CustomFilterChip(
                label: 'All Groups',
                isSelected: false,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              CustomFilterChip(
                label: 'Sort',
                isSelected: false,
                icon: Icons.sort,
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Collection Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // Fixed aspect ratio to prevent overflow
              ),
              itemCount: 15,
              itemBuilder: (context, index) {
                return PhotocardWidget(
                  groupName: _mockGroups[index % _mockGroups.length],
                  memberName: _mockMembers[index % _mockMembers.length],
                  albumName: _mockAlbums[index % _mockAlbums.length],
                  rarity: _mockRarities[index % _mockRarities.length],
                  isOwned: true,
                  isWishlisted: index % 3 == 0,
                  onTap: () {
                    context.push('/photocard/$index');
                  },
                  onOwnedToggle: () {
                    // TODO: Toggle owned status
                  },
                  onWishlistToggle: () {
                    // TODO: Toggle wishlist status
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              const Text(
                '23 wanted cards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const Spacer(),
              CustomFilterChip(
                label: 'Priority',
                isSelected: false,
                icon: Icons.star,
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Wishlist Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // Fixed aspect ratio to prevent overflow
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return PhotocardWidget(
                  groupName: _mockGroups[index % _mockGroups.length],
                  memberName: _mockMembers[index % _mockMembers.length],
                  albumName: _mockAlbums[index % _mockAlbums.length],
                  rarity: _mockRarities[index % _mockRarities.length],
                  isOwned: false,
                  isWishlisted: true,
                  onTap: () {
                    context.push('/photocard/$index');
                  },
                  onOwnedToggle: () {
                    // TODO: Toggle owned status
                  },
                  onWishlistToggle: () {
                    // TODO: Toggle wishlist status
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'My Albums',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const Spacer(),
              const PremiumBadge(text: '2/2 Albums', isSmall: true),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Albums List
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _AlbumCard(
                    title: index == 0 ? 'NewJeans Collection' : 'BLACKPINK Favorites',
                    subtitle: index == 0 ? '25 photocards' : '18 photocards',
                    progress: index == 0 ? 0.7 : 0.4,
                    coverImages: _mockGroups.take(4).toList(),
                    onTap: () {
                      // TODO: Navigate to album detail
                    },
                  ),
                );
              },
            ),
          ),
          
          // Add Album Button (Premium)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: AppTheme.primaryPurple,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create New Album',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upgrade to Premium for unlimited albums',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                const PremiumBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
  final Color color;
  final IconData icon;
  final bool isPremium;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              if (isPremium) const PremiumBadge(isSmall: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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

class _AlbumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final List<String> coverImages;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.coverImages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Cover Images Stack
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                ...coverImages.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  return Positioned(
                    left: index * 8.0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo,
                        size: 20,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Album Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.mediumGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Icon(
            Icons.chevron_right,
            color: AppTheme.darkGray,
          ),
        ],
      ),
    );
  }
}
