import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            
            // Premium Banner
            _buildPremiumBanner(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseTab(),
                  _buildMyTradesTab(),
                  _buildMessagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateTradeDialog();
        },
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: AppTheme.white,
        icon: const Icon(Icons.add),
        label: const Text('New Trade'),
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
                  'Trading Hub',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trade photocards with other collectors',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          const PremiumBadge(),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.swap_horiz,
            color: AppTheme.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Trading Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Unlimited trades, priority matching, and secure messaging',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
          SecondaryButton(
            text: 'Upgrade',
            isFullWidth: false,
            onPressed: () {
              // TODO: Navigate to premium upgrade
            },
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
          Tab(text: 'Browse'),
          Tab(text: 'My Trades'),
          Tab(text: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search trades...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CustomFilterChip(
                label: 'Filter',
                isSelected: false,
                icon: Icons.filter_list,
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Trade Listings
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _TradeCard(
                    traderName: 'User${index + 1}',
                    traderRating: 4.5 + (index % 3) * 0.1,
                    tradeCount: 15 + index * 3,
                    offering: 'NewJeans Haerin - Get Up',
                    wanting: 'BLACKPINK Jennie - Born Pink',
                    timeAgo: '${index + 1}h ago',
                    onTap: () {
                      _showTradeDetailDialog();
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

  Widget _buildMyTradesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Active',
                  value: '3',
                  color: AppTheme.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Completed',
                  value: '12',
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Rating',
                  value: '4.8',
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // My Trade Listings
          const Text(
            'My Trade Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _MyTradeCard(
                    offering: 'aespa Karina - MY WORLD',
                    wanting: 'IVE Wonyoung - LOVE DIVE',
                    status: index == 0 ? 'Active' : index == 1 ? 'Pending' : 'Completed',
                    responses: index + 2,
                    timeAgo: '${index + 1}d ago',
                    onTap: () {
                      _showMyTradeDetailDialog();
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

  Widget _buildMessagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _MessageCard(
              userName: 'User${index + 1}',
              lastMessage: index % 2 == 0 
                  ? 'Hi! I\'m interested in your NewJeans card'
                  : 'Thanks for the trade! 5 stars ⭐',
              timeAgo: '${index + 1}h ago',
              isUnread: index < 2,
              onTap: () {
                // TODO: Navigate to chat
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateTradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Trade'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select cards you want to offer and what you\'re looking for.'),
            SizedBox(height: 16),
            PremiumBadge(text: 'Premium Feature'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to create trade flow
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showTradeDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trade Details'),
        content: const Text('View full trade details and contact trader.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Contact trader
            },
            child: const Text('Contact Trader'),
          ),
        ],
      ),
    );
  }

  void _showMyTradeDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Trade'),
        content: const Text('Manage your trade request and view responses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Manage trade
            },
            child: const Text('Manage'),
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
}

class _TradeCard extends StatelessWidget {
  final String traderName;
  final double traderRating;
  final int tradeCount;
  final String offering;
  final String wanting;
  final String timeAgo;
  final VoidCallback onTap;

  const _TradeCard({
    required this.traderName,
    required this.traderRating,
    required this.tradeCount,
    required this.offering,
    required this.wanting,
    required this.timeAgo,
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
          // Trader Info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.lightPurple.withOpacity(0.3),
                child: Text(
                  traderName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      traderName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: traderRating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppTheme.warning,
                          ),
                          itemCount: 5,
                          itemSize: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($tradeCount trades)',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Trade Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offering:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                    Text(
                      offering,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swap_horiz,
                color: AppTheme.primaryPurple,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Wanting:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentPink,
                      ),
                    ),
                    Text(
                      wanting,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.charcoal,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyTradeCard extends StatelessWidget {
  final String offering;
  final String wanting;
  final String status;
  final int responses;
  final String timeAgo;
  final VoidCallback onTap;

  const _MyTradeCard({
    required this.offering,
    required this.wanting,
    required this.status,
    required this.responses,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Active' 
        ? AppTheme.success 
        : status == 'Pending' 
            ? AppTheme.warning 
            : AppTheme.darkGray;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offering:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                    Text(
                      offering,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swap_horiz,
                color: AppTheme.primaryPurple,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Wanting:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentPink,
                      ),
                    ),
                    Text(
                      wanting,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.charcoal,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$responses response${responses != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String timeAgo;
  final bool isUnread;
  final VoidCallback onTap;

  const _MessageCard({
    required this.userName,
    required this.lastMessage,
    required this.timeAgo,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      color: isUnread ? AppTheme.lightPurple.withOpacity(0.1) : null,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.lightPurple.withOpacity(0.3),
                child: Text(
                  userName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
              if (isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lastMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? AppTheme.charcoal : AppTheme.darkGray,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
