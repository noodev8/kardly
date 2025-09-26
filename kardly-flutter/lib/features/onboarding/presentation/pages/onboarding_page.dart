import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Collect & Track',
      subtitle: 'Keep track of your K-Pop photocard collection',
      description: 'Mark cards as owned or add them to your wishlist. Organize your collection with beautiful album-style layouts.',
      icon: Icons.photo_library,
      color: AppTheme.primaryPurple,
    ),
    OnboardingItem(
      title: 'Discover & Search',
      subtitle: 'Find photocards from your favorite groups',
      description: 'Browse thousands of photocards by group, member, album, and era. Discover rare cards and new releases.',
      icon: Icons.search,
      color: AppTheme.accentPink,
    ),
    OnboardingItem(
      title: 'Trade & Connect',
      subtitle: 'Trade with collectors worldwide',
      description: 'Connect with other fans, trade photocards safely, and build your dream collection together.',
      icon: Icons.swap_horiz,
      color: AppTheme.mintAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _goToAuth(),
                  child: const Text('Skip'),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingItems[index]);
                },
              ),
            ),
            
            // Page Indicator
            _buildPageIndicator(),
            
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 60,
              color: item.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.darkGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _onboardingItems.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index 
                  ? AppTheme.primaryPurple 
                  : AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back Button
          if (_currentPage > 0)
            Expanded(
              child: SecondaryButton(
                text: 'Back',
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          // Next/Get Started Button
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: PrimaryButton(
              text: _currentPage == _onboardingItems.length - 1 
                  ? 'Get Started' 
                  : 'Next',
              onPressed: () {
                if (_currentPage == _onboardingItems.length - 1) {
                  _goToAuth();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToAuth() {
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
