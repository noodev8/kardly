import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/collection/presentation/pages/collection_page.dart';
import '../../features/trading/presentation/pages/trading_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import 'package:kardly/features/photocard/presentation/pages/photocard_detail_page.dart';
import '../../features/photocard/presentation/pages/add_photocard_page.dart';
import '../../shared/presentation/widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Onboarding and Auth Routes
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/collection',
            name: 'collection',
            builder: (context, state) => const CollectionPage(),
          ),
          GoRoute(
            path: '/trading',
            name: 'trading',
            builder: (context, state) => const TradingPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Photocard Detail Route
      GoRoute(
        path: '/photocard/:id',
        name: 'photocard-detail',
        builder: (context, state) {
          final photocardId = state.pathParameters['id'] ?? '0';
          return PhotocardDetailPage(photocardId: photocardId);
        },
      ),

      // Add Photocard Route
      GoRoute(
        path: '/add-photocard',
        name: 'add-photocard',
        builder: (context, state) => const AddPhotocardPage(),
      ),
    ],
  );
}
