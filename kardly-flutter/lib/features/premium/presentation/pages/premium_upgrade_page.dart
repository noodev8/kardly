import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';

class PremiumUpgradePage extends StatefulWidget {
  const PremiumUpgradePage({super.key});

  @override
  State<PremiumUpgradePage> createState() => _PremiumUpgradePageState();
}

class _PremiumUpgradePageState extends State<PremiumUpgradePage> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),
            
            const SizedBox(height: 32),
            
            // Pricing Toggle
            _buildPricingToggle(),
            
            const SizedBox(height: 24),
            
            // Pricing Cards
            _buildPricingCards(),
            
            const SizedBox(height: 32),
            
            // Features List
            _buildFeaturesList(),
            
            const SizedBox(height: 32),
            
            // CTA Button
            _buildCTAButton(),
            
            const SizedBox(height: 16),
            
            // Terms
            _buildTerms(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            size: 60,
            color: AppTheme.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock Premium Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Get unlimited access to all features and take your collection to the next level',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.mediumGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isYearly = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isYearly ? AppTheme.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !_isYearly ? AppTheme.charcoal : AppTheme.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isYearly = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isYearly ? AppTheme.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yearly',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isYearly ? AppTheme.charcoal : AppTheme.darkGray,
                      ),
                    ),
                    if (_isYearly) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Save 37%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards() {
    return Row(
      children: [
        // Free Plan
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '£0',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const Text(
                  'forever',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '• 100 photocards max\n• 2 albums/lists max\n• Basic search\n• Collection tracking',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Premium Plan
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.accentPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isYearly ? '£29.99' : '£3.99',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  Text(
                    _isYearly ? 'per year' : 'per month',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  if (_isYearly) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '£2.50/month',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '• Unlimited photocards\n• Unlimited albums\n• Valuation tools\n• Premium themes\n• Priority support',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.charcoal,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Everything',
        description: 'No limits on photocards, albums, or collections',
        isPremium: true,
      ),

      _FeatureItem(
        icon: Icons.trending_up,
        title: 'Market Valuation',
        description: 'Real-time pricing and value tracking',
        isPremium: true,
      ),
      _FeatureItem(
        icon: Icons.palette,
        title: 'Custom Themes',
        description: 'Personalize your app with exclusive themes',
        isPremium: true,
      ),
      _FeatureItem(
        icon: Icons.cloud_upload,
        title: 'Upload Cards',
        description: 'Add new photocards to the database',
        isPremium: true,
      ),
      _FeatureItem(
        icon: Icons.support_agent,
        title: 'Priority Support',
        description: 'Get help faster with premium support',
        isPremium: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoal,
                          ),
                        ),
                        if (feature.isPremium) ...[
                          const SizedBox(width: 8),
                          const PremiumBadge(isSmall: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildCTAButton() {
    return PrimaryButton(
      text: _isYearly 
          ? 'Start Premium - £29.99/year' 
          : 'Start Premium - £3.99/month',
      onPressed: () {
        _showPaymentDialog();
      },
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        const Text(
          'Cancel anytime. No commitments.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const Text(' • ', style: TextStyle(color: AppTheme.darkGray)),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You\'re about to upgrade to Premium!'),
            const SizedBox(height: 16),
            Text(
              _isYearly 
                  ? 'Annual subscription: £29.99/year'
                  : 'Monthly subscription: £3.99/month',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryPurple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process payment
              _showSuccessDialog();
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Premium! 🎉'),
        content: const Text('You now have access to all premium features. Enjoy your enhanced Kardly experience!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final bool isPremium;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPremium,
  });
}
