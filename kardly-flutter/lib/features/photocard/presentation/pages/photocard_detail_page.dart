import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class PhotocardDetailPage extends StatefulWidget {
  final String photocardId;
  
  const PhotocardDetailPage({
    super.key,
    required this.photocardId,
  });

  @override
  State<PhotocardDetailPage> createState() => _PhotocardDetailPageState();
}

class _PhotocardDetailPageState extends State<PhotocardDetailPage> {
  bool isOwned = false;
  bool isWishlisted = false;
  
  // Mock data - in real app this would come from API/database
  late Map<String, dynamic> photocardData;
  
  @override
  void initState() {
    super.initState();
    _loadPhotocardData();
  }
  
  void _loadPhotocardData() {
    // Mock data based on photocard ID
    final id = int.tryParse(widget.photocardId) ?? 0;
    final groups = ['NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY'];
    final members = ['Minji', 'Jennie', 'Karina', 'Wonyoung', 'Yeji'];
    final albums = ['Get Up', 'Born Pink', 'MY WORLD', 'I\'ve IVE', 'CHECKMATE'];
    final rarities = ['Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'];
    
    photocardData = {
      'id': widget.photocardId,
      'groupName': groups[id % groups.length],
      'memberName': members[id % members.length],
      'albumName': albums[id % albums.length],
      'rarity': rarities[id % rarities.length],
      'releaseDate': '2024-${(id % 12) + 1}-${(id % 28) + 1}',
      'description': 'Official photocard from ${albums[id % albums.length]} album featuring ${members[id % members.length]}. This card showcases beautiful styling and high-quality printing.',
      'cardNumber': '${id + 1}/55',
      'condition': 'Mint',
      'imageUrl': null, // Would be actual image URL in real app
    };
    
    // Mock owned/wishlist status
    isOwned = id % 4 == 0;
    isWishlisted = id % 3 == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.lightGray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${photocardData['groupName']} - ${photocardData['memberName']}',
          style: const TextStyle(
            color: AppTheme.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: AppTheme.charcoal,
            ),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photocard Image
            _buildPhotocardImage(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 24),
            
            // Card Information
            _buildCardInformation(),
            
            const SizedBox(height: 24),
            
            // Description
            _buildDescription(),
            
            const SizedBox(height: 24),
            
            // Related Cards
            _buildRelatedCards(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhotocardImage() {
    return Center(
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Container(
          width: 250,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightPurple.withOpacity(0.3),
                AppTheme.primaryPurple.withOpacity(0.1),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Placeholder image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppTheme.lightGray,
                  child: const Icon(
                    Icons.photo,
                    size: 80,
                    color: AppTheme.darkGray,
                  ),
                ),
                
                // Rarity Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(photocardData['rarity']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      photocardData['rarity'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                // Card Number
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      photocardData['cardNumber'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: isOwned ? 'Remove from Collection' : 'Add to Collection',
            icon: isOwned ? Icons.check_circle : Icons.add_circle_outline,
            onPressed: () {
              setState(() {
                isOwned = !isOwned;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isOwned 
                        ? 'Added to your collection!' 
                        : 'Removed from collection',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SecondaryButton(
            text: isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
            icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
            onPressed: () {
              setState(() {
                isWishlisted = !isWishlisted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWishlisted 
                        ? 'Added to wishlist!' 
                        : 'Removed from wishlist',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardInformation() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Group', photocardData['groupName']),
          _buildInfoRow('Member', photocardData['memberName']),
          _buildInfoRow('Album', photocardData['albumName']),
          _buildInfoRow('Rarity', photocardData['rarity']),
          _buildInfoRow('Card Number', photocardData['cardNumber']),
          _buildInfoRow('Release Date', photocardData['releaseDate']),
          _buildInfoRow('Condition', photocardData['condition']),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            photocardData['description'],
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More from this Album',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                child: PhotocardWidget(
                  groupName: photocardData['groupName'],
                  memberName: 'Member ${index + 1}',
                  albumName: photocardData['albumName'],
                  rarity: ['Common', 'Rare', 'Super Rare'][index % 3],
                  useAspectRatio: false,
                  onTap: () {
                    context.push('/photocard/${index + 100}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return AppTheme.darkGray;
      case 'rare':
        return AppTheme.info;
      case 'super rare':
        return AppTheme.primaryPurple;
      case 'ultra rare':
        return AppTheme.accentPink;
      case 'legendary':
        return AppTheme.warning;
      default:
        return AppTheme.darkGray;
    }
  }
}
