import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/page_layout.dart';
import '../providers/collection_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    // Load photocards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Wishlist',
      subtitle: 'Cards you want to collect',
      showBackButton: true,
      onBackPressed: () => context.pop(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Text(
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
                      style: const TextStyle(
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

          final wishlistPhotocards = provider.wishlistCards;

          if (wishlistPhotocards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 64,
                      color: AppTheme.darkGray.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No wishlist items yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add photocards to your wishlist to track what you want to collect',
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
                      child: const Text('Add to wishlist'),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: wishlistPhotocards.length,
            itemBuilder: (context, index) {
              final photocard = wishlistPhotocards[index];
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
          );
        },
      ),
    );
  }
}
