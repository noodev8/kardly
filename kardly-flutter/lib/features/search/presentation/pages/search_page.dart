import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'All';
  String _selectedRarity = 'All';
  String _selectedSort = 'Newest';
  bool _showFilters = false;

  final List<String> _groups = [
    'All', 'NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY', 'TWICE', 'Red Velvet'
  ];
  
  final List<String> _rarities = [
    'All', 'Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'
  ];
  
  final List<String> _sortOptions = [
    'Newest', 'Oldest', 'A-Z', 'Z-A', 'Price: Low to High', 'Price: High to Low'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),
            
            // Filters
            if (_showFilters) _buildFilters(),
            
            // Results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search photocards, groups, members...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.darkGray,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButtonCustom(
                icon: _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                backgroundColor: _showFilters 
                    ? AppTheme.primaryPurple 
                    : AppTheme.lightPurple.withOpacity(0.3),
                iconColor: _showFilters 
                    ? AppTheme.white 
                    : AppTheme.primaryPurple,
              ),
            ],
          ),
          
          // Quick Filter Chips
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomFilterChip(
                  label: 'Popular',
                  isSelected: false,
                  icon: Icons.trending_up,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                CustomFilterChip(
                  label: 'New Releases',
                  isSelected: false,
                  icon: Icons.new_releases,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                CustomFilterChip(
                  label: 'Rare Cards',
                  isSelected: false,
                  icon: Icons.star,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                CustomFilterChip(
                  label: 'Trading',
                  isSelected: false,
                  icon: Icons.swap_horiz,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Group Filter
          const Text(
            'Group',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _groups.map((group) {
              return CustomFilterChip(
                label: group,
                isSelected: _selectedGroup == group,
                onTap: () {
                  setState(() {
                    _selectedGroup = group;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Rarity Filter
          const Text(
            'Rarity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rarities.map((rarity) {
              return CustomFilterChip(
                label: rarity,
                isSelected: _selectedRarity == rarity,
                onTap: () {
                  setState(() {
                    _selectedRarity = rarity;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Sort Options
          Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSort = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Header
          Row(
            children: [
              Text(
                'Found 247 photocards',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.charcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.grid_view),
                onPressed: () {},
                color: AppTheme.primaryPurple,
              ),
              IconButton(
                icon: const Icon(Icons.view_list),
                onPressed: () {},
                color: AppTheme.darkGray,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Results Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // Fixed aspect ratio to prevent overflow
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return PhotocardWidget(
                  groupName: _mockGroups[index % _mockGroups.length],
                  memberName: _mockMembers[index % _mockMembers.length],
                  albumName: _mockAlbums[index % _mockAlbums.length],
                  rarity: _mockRarities[index % _mockRarities.length],
                  isOwned: index % 4 == 0,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mock data
  static const List<String> _mockGroups = [
    'NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY', 'TWICE', 'Red Velvet', 'NMIXX'
  ];
  
  static const List<String> _mockMembers = [
    'Minji', 'Hanni', 'Danielle', 'Haerin', 'Hyein', 'Jisoo', 'Jennie', 'Rosé'
  ];
  
  static const List<String> _mockAlbums = [
    'Get Up', 'NewJeans', 'OMG', 'Ditto', 'Born Pink', 'MY WORLD', 'LOVE DIVE'
  ];
  
  static const List<String> _mockRarities = [
    'Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'
  ];
}
