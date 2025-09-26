import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showShimmer;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
    this.showShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppTheme.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.08),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

class PhotocardWidget extends StatelessWidget {
  final String? imageUrl;
  final String? groupName;
  final String? memberName;
  final String? albumName;
  final bool isOwned;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onOwnedToggle;
  final VoidCallback? onWishlistToggle;
  final bool useAspectRatio;
  final String? rarity;
  final bool showActions;

  const PhotocardWidget({
    super.key,
    this.imageUrl,
    this.groupName,
    this.memberName,
    this.albumName,
    this.isOwned = false,
    this.isWishlisted = false,
    this.onTap,
    this.onOwnedToggle,
    this.onWishlistToggle,
    this.rarity,
    this.showActions = true,
    this.useAspectRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photocard Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.photo,
                        size: 40,
                        color: AppTheme.darkGray,
                      ),
                    )
                  : Stack(
                      children: [
                        // Rarity Badge
                        if (rarity != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRarityColor(rarity!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                rarity!,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        // Action Buttons
                        if (showActions)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Column(
                              children: [
                                _ActionButton(
                                  icon: isOwned 
                                      ? Icons.check_circle 
                                      : Icons.check_circle_outline,
                                  isActive: isOwned,
                                  onTap: onOwnedToggle,
                                ),
                                const SizedBox(height: 4),
                                _ActionButton(
                                  icon: isWishlisted 
                                      ? Icons.favorite 
                                      : Icons.favorite_border,
                                  isActive: isWishlisted,
                                  onTap: onWishlistToggle,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Card Info - Simple container to prevent overflow
          Container(
            height: useAspectRatio ? 35 : 25,
            padding: const EdgeInsets.only(top: 4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (groupName != null)
                    Text(
                      groupName!,
                      style: TextStyle(
                        fontSize: useAspectRatio ? 9 : 8,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPurple,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (memberName != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      memberName!,
                      style: TextStyle(
                        fontSize: useAspectRatio ? 10 : 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (useAspectRatio) {
      return AspectRatio(
        aspectRatio: 0.75,
        child: cardContent,
      );
    } else {
      return cardContent;
    }
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? AppTheme.primaryPurple : AppTheme.darkGray,
        ),
      ),
    );
  }
}
