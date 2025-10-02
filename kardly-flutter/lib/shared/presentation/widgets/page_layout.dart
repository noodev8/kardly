import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_header.dart';

/// Common page layout with header and content area
class PageLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;
  final bool scrollable;

  const PageLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.headerTrailing,
    this.showBackButton = false,
    this.onBackPressed,
    required this.child,
    this.contentPadding = const EdgeInsets.all(16),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          // Header that covers status bar
          AppHeader(
            title: title,
            subtitle: subtitle,
            trailing: headerTrailing,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed,
          ),
          
          // Rest of content with SafeArea
          Expanded(
            child: SafeArea(
              top: false, // Don't add top safe area since header covers it
              child: scrollable
                  ? SingleChildScrollView(
                      padding: contentPadding,
                      child: child,
                    )
                  : Padding(
                      padding: contentPadding ?? EdgeInsets.zero,
                      child: child,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
