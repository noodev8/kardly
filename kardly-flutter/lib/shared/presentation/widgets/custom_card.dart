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
            color: AppTheme.primaryPurple.withValues(alpha: 0.08),
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
  final bool isFavorite;
  final VoidCallback? onTap;
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
    this.isFavorite = false,
    this.onTap,
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
                        // Status Indicators (top-right corner)
                        if (showActions && (isOwned || isWishlisted || isFavorite))
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Column(
                              children: [
                                if (isFavorite)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warning.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                if (isFavorite && (isOwned || isWishlisted))
                                  const SizedBox(height: 4),
                                if (isOwned)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                if (isOwned && isWishlisted)
                                  const SizedBox(height: 4),
                                if (isWishlisted)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentPink.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: AppTheme.white,
                                    ),
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


