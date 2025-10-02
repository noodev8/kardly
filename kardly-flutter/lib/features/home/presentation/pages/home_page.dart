import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _photocards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotocards();
  }

  Future<void> _loadPhotocards() async {
    try {
      final response = await ApiService.getPhotocards(limit: 10);
      setState(() {
        _photocards = List<Map<String, dynamic>>.from(response['photocards']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading photocards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          // Header that covers status bar
          _buildHeader(context),

          // Rest of content with SafeArea
          Expanded(
            child: SafeArea(
              top: false, // Don't add top safe area since header covers it
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Trending Photocards
                    _buildTrendingSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, statusBarHeight + 24, 24, 45),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.accentPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.waving_hand,
              color: AppTheme.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildQuickActions(BuildContext context) {
    return Row(
          children: [
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
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_photo_alternate,
                title: 'Add Photocard',
                subtitle: 'Upload new card',
                color: AppTheme.darkPurple,
                onTap: () {
                  context.push('/add-photocard');
                },
              ),
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
              'Recent Photocards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoal,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.go('/collection');
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _photocards.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: AppTheme.darkGray.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No photocards yet',
                            style: TextStyle(
                              color: AppTheme.darkGray.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              context.push('/add-photocard');
                            },
                            child: const Text('Add your first photocard'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photocards.length,
                      itemBuilder: (context, index) {
                        final photocard = _photocards[index];
                        return Container(
                          width: 130,
                          margin: const EdgeInsets.only(right: 12),
                          child: PhotocardWidget(
                            imageUrl: photocard['image_url'],
                            groupName: photocard['group_name'],
                            memberName: photocard['member_stage_name'] ?? photocard['member_name'],
                            albumName: photocard['album_title'],
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
    );
  }


}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const waveHeight = 8.0;
    final waveLength = size.width / 3;

    // Start from top-left corner
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - waveHeight);

    // Create the wavy bottom edge
    for (double x = size.width; x >= 0; x -= waveLength / 20) {
      final y = size.height - waveHeight +
          waveHeight * math.sin((x / waveLength) * 2 * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(0, size.height - waveHeight);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
