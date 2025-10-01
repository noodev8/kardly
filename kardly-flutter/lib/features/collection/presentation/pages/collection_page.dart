import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../providers/collection_provider.dart';

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
    // Load photocards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollection();
    });
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
                  _buildUnallocatedTab(),
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
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Owned',
                  value: '${provider.totalOwnedCount}',
                  subtitle: 'photocards',
                  color: AppTheme.success,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Wishlist',
                  value: '${provider.totalWishlistCount}',
                  subtitle: 'wanted',
                  color: AppTheme.accentPink,
                  icon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Value',
                  value: '£${provider.estimatedValue.toStringAsFixed(0)}',
                  subtitle: 'estimated',
                  color: AppTheme.warning,
                  icon: Icons.trending_up,
                  isPremium: true,
                ),
              ),
            ],
          ),
        );
      },
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
          Tab(text: 'Unallocated'),
        ],
      ),
    );
  }

  Widget _buildOwnedTab() {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.charcoal),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () => provider.loadCollection(),
                ),
              ],
            ),
          );
        }

        final photocards = provider.ownedCards;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bar
              Row(
                children: [
                  Text(
                    '${photocards.length} photocards',
                    style: const TextStyle(
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
                child: photocards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: AppTheme.darkGray,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No photocards yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start building your collection!',
                              style: TextStyle(color: AppTheme.darkGray),
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Add Photocard',
                              icon: Icons.add,
                              onPressed: () => context.push('/add-photocard'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: photocards.length,
                        itemBuilder: (context, index) {
                          final photocard = photocards[index];
                          return PhotocardWidget(
                            imageUrl: photocard.imageUrl,
                            groupName: photocard.groupName,
                            memberName: photocard.memberName,
                            albumName: photocard.albumName,
                            isOwned: photocard.isOwned,
                            isWishlisted: photocard.isWishlisted,
                            onTap: () {
                              context.push('/photocard/${photocard.id}');
                            },
                            onOwnedToggle: () {
                              provider.toggleOwned(photocard.id);
                            },
                            onWishlistToggle: () {
                              provider.toggleWishlist(photocard.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistTab() {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        final wishlistCards = provider.wishlistCards;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bar
              Row(
                children: [
                  Text(
                    '${wishlistCards.length} wanted cards',
                    style: const TextStyle(
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
                child: wishlistCards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: AppTheme.darkGray,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No wishlist items yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add photocards you want to collect!',
                              style: TextStyle(color: AppTheme.darkGray),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: wishlistCards.length,
                        itemBuilder: (context, index) {
                          final photocard = wishlistCards[index];
                          return PhotocardWidget(
                            imageUrl: photocard.imageUrl,
                            groupName: photocard.groupName,
                            memberName: photocard.memberName,
                            albumName: photocard.albumName,
                            isOwned: photocard.isOwned,
                            isWishlisted: photocard.isWishlisted,
                            onTap: () {
                              context.push('/photocard/${photocard.id}');
                            },
                            onOwnedToggle: () {
                              provider.toggleOwned(photocard.id);
                            },
                            onWishlistToggle: () {
                              provider.toggleWishlist(photocard.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnallocatedTab() {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.charcoal),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () => provider.loadCollection(),
                ),
              ],
            ),
          );
        }

        final photocards = provider.unallocatedCards;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unallocated Cards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${photocards.length} cards',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Collection Grid
              Expanded(
                child: photocards.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: AppTheme.darkGray,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No unallocated cards',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoal,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cards you add will appear here until you mark them as owned or wishlisted',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.darkGray),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: photocards.length,
                        itemBuilder: (context, index) {
                          final photocard = photocards[index];
                          return PhotocardWidget(
                            imageUrl: photocard.imageUrl,
                            groupName: photocard.groupName,
                            memberName: photocard.memberName,
                            albumName: photocard.albumName,
                            isOwned: photocard.isOwned,
                            isWishlisted: photocard.isWishlisted,
                            onTap: () {
                              context.push('/photocard/${photocard.id}');
                            },
                            onOwnedToggle: () {
                              provider.toggleOwned(photocard.id);
                            },
                            onWishlistToggle: () {
                              provider.toggleWishlist(photocard.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
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


