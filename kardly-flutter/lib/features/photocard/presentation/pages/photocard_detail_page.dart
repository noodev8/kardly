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
  bool isFavorite = false;
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
        // Set the collection status from API response
        isOwned = photocard['is_owned'] ?? false;
        isWishlisted = photocard['is_wishlisted'] ?? false;
        isFavorite = photocard['is_favorite'] ?? false;

        // Debug logging
        debugPrint('Photocard ${photocard['id']}: isOwned=$isOwned, isWishlisted=$isWishlisted, isFavorite=$isFavorite');
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

            const SizedBox(height: 16),



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
    return Column(
      children: [
        // First button - Collection status
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: isOwned ? 'Owned ✓' : 'Add to Collection',
            icon: isOwned ? Icons.check_circle : Icons.add_circle_outline,
            onPressed: () async {
              try {
                final response = await ApiService.toggleOwned(widget.photocardId);
                final newIsOwned = response['is_owned'] ?? false;

                setState(() {
                  isOwned = newIsOwned;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newIsOwned
                            ? 'Added to your collection!'
                            : 'Removed from collection',
                      ),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        // Second button - Wishlist status
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            text: isWishlisted ? 'Wishlisted ♥' : 'Add to Wishlist',
            icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
            onPressed: () async {
              try {
                final response = await ApiService.toggleWishlist(widget.photocardId);
                final newIsWishlisted = response['is_wishlisted'] ?? false;

                setState(() {
                  isWishlisted = newIsWishlisted;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newIsWishlisted
                            ? 'Added to wishlist!'
                            : 'Removed from wishlist',
                      ),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        // Third button - Favorite status
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            text: isFavorite ? 'Favorited' : 'Add to Favorites',
            icon: isFavorite ? Icons.star : Icons.star_border,
            onPressed: () async {
              try {
                final response = await ApiService.toggleFavorite(widget.photocardId);
                final newIsFavorite = response['is_favorite'] ?? false;

                setState(() {
                  isFavorite = newIsFavorite;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newIsFavorite
                            ? 'Added to favorites!'
                            : 'Removed from favorites',
                      ),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ),

        const SizedBox(height: 24),
        // Edit and Delete buttons row
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Edit',
                icon: Icons.edit,
                onPressed: () {
                  _showEditDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                text: 'Delete',
                icon: Icons.delete,
                onPressed: () {
                  _showDeleteDialog();
                },
              ),
            ),
          ],
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

  void _showEditDialog() {
    // For now, show a simple dialog - in a real app you'd want a proper edit form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Photocard'),
          content: const Text('Edit functionality coming soon!\n\nThis would allow you to update the group, member, and album information for this photocard.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Photocard'),
          content: const Text('Are you sure you want to delete this photocard? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                try {
                  await ApiService.deletePhotocard(widget.photocardId);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photocard deleted successfully'),
                        backgroundColor: AppTheme.success,
                      ),
                    );

                    // Navigate back to previous page
                    context.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting photocard: $e'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
