import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/page_layout.dart';
import '../providers/collection_provider.dart';

class OwnedCardsPage extends StatefulWidget {
  const OwnedCardsPage({super.key});

  @override
  State<OwnedCardsPage> createState() => _OwnedCardsPageState();
}

class _OwnedCardsPageState extends State<OwnedCardsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load photocards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollection();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterPhotocards(List<dynamic> photocards) {
    if (_searchQuery.isEmpty) return photocards;

    return photocards.where((photocard) {
      final groupName = (photocard.groupName ?? '').toLowerCase();
      final memberName = (photocard.memberName ?? '').toLowerCase();
      final albumName = (photocard.albumName ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return groupName.contains(query) ||
             memberName.contains(query) ||
             albumName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Owned Cards',
      subtitle: 'Your photocard collection',
      showBackButton: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Consumer<CollectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.error.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading cards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: 'Retry',
                      onPressed: () {
                        provider.loadCollection();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final ownedPhotocards = provider.ownedCards;

          if (ownedPhotocards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: AppTheme.darkGray.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No owned cards yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add photocards to your collection to see them here',
                      style: TextStyle(
                        color: AppTheme.darkGray.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.push('/add-photocard');
                      },
                      child: const Text('Add your first photocard'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredPhotocards = _filterPhotocards(ownedPhotocards);

          return Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by group, member, or album...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.darkGray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.darkGray),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Results count
              if (filteredPhotocards.length != ownedPhotocards.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Showing ${filteredPhotocards.length} of ${ownedPhotocards.length} cards',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ),

              // Grid
              GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredPhotocards.length,
            itemBuilder: (context, index) {
              final photocard = filteredPhotocards[index];
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
              );
            },
          ),
            ],
          );
        },
      ),
    );
  }
}
