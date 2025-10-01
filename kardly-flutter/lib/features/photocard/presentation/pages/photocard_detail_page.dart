import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
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
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? photocardData;

  @override
  void initState() {
    super.initState();
    _loadPhotocardData();
  }

  Future<void> _loadPhotocardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all photocards and find the one with matching ID
      final response = await ApiService.getPhotocards(limit: 100);
      final photocards = response['photocards'] as List<Map<String, dynamic>>;

      final photocard = photocards.firstWhere(
        (p) => p['id'] == widget.photocardId,
        orElse: () => {},
      );

      if (photocard.isEmpty) {
        setState(() {
          _error = 'Photocard not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        photocardData = {
          'id': photocard['id'],
          'groupName': photocard['group_name'] ?? 'Unknown Group',
          'memberName': photocard['member_stage_name'] ?? photocard['member_name'] ?? 'Unknown Member',
          'albumName': photocard['album_title'] ?? 'Unknown Album',
          'imageUrl': photocard['image_url'],
          'createdAt': photocard['created_at'],
          'description': 'Official photocard featuring ${photocard['member_stage_name'] ?? photocard['member_name'] ?? 'Unknown Member'}.',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load photocard: $e';
        _isLoading = false;
      });
    }
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
          _isLoading
              ? 'Loading...'
              : photocardData != null
                  ? '${photocardData!['groupName']} - ${photocardData!['memberName']}'
                  : 'Photocard',
          style: const TextStyle(
            color: AppTheme.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          if (!_isLoading && photocardData != null)
            IconButton(
              icon: const Icon(
                Icons.share,
                color: AppTheme.charcoal,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon!')),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.charcoal,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Go Back',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
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
    if (photocardData == null) return const SizedBox.shrink();

    return Center(
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Container(
          width: 250,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: photocardData!['imageUrl'] != null
                ? Image.network(
                    photocardData!['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.lightGray,
                        child: const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: AppTheme.darkGray,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.lightGray,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.lightGray,
                    child: const Icon(
                      Icons.photo,
                      size: 80,
                      color: AppTheme.darkGray,
                    ),
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
    if (photocardData == null) return const SizedBox.shrink();

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
          _buildInfoRow('Group', photocardData!['groupName'] ?? 'Unknown'),
          _buildInfoRow('Member', photocardData!['memberName'] ?? 'Unknown'),
          _buildInfoRow('Album', photocardData!['albumName'] ?? 'Unknown'),
          if (photocardData!['createdAt'] != null)
            _buildInfoRow('Added', _formatDate(photocardData!['createdAt'])),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
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
    if (photocardData == null) return const SizedBox.shrink();

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
            photocardData!['description'] ?? 'No description available.',
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
    // Hide related cards section for now since we don't have album-based filtering yet
    return const SizedBox.shrink();
  }
}
