import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _currentProfile;
  List<Activity> _recentActivity = [];
  bool _isLoading = false;

  UserProfile? get currentProfile => _currentProfile;
  List<Activity> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;

  Future<void> loadProfile([String? userId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
      
      _currentProfile = _generateMockProfile();
      _recentActivity = _generateMockActivity();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? location,
  }) async {
    if (_currentProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Update via API
      await Future.delayed(const Duration(seconds: 1));
      
      _currentProfile = _currentProfile!.copyWith(
        username: username ?? _currentProfile!.username,
        bio: bio ?? _currentProfile!.bio,
        location: location ?? _currentProfile!.location,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String userId) async {
    // TODO: Implement follow functionality
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    // TODO: Implement unfollow functionality
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  UserProfile _generateMockProfile() {
    return UserProfile(
      id: 'current_user',
      username: 'KpopFan2024',
      email: 'user@example.com',
      bio: 'NewJeans & BLACKPINK collector',
      location: 'London, UK',
      joinDate: DateTime(2024, 3, 1),
      isPremium: true,
      photocardCount: 127,
      wishlistCount: 43,
      followersCount: 89,
      followingCount: 156,
      traderRating: 4.8,
      completedTrades: 24,
      profileImageUrl: null,
    );
  }

  List<Activity> _generateMockActivity() {
    return [
      Activity(
        id: 'activity_1',
        type: ActivityType.addedToCollection,
        description: 'Added NewJeans Haerin to collection',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Activity(
        id: 'activity_2',
        type: ActivityType.addedToWishlist,
        description: 'Added BLACKPINK Jennie to wishlist',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Activity(
        id: 'activity_3',
        type: ActivityType.completedTrade,
        description: 'Completed trade with User123',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Activity(
        id: 'activity_4',
        type: ActivityType.receivedRating,
        description: 'Received 5-star rating from trader',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String location;
  final DateTime joinDate;
  final bool isPremium;
  final int photocardCount;
  final int wishlistCount;
  final int followersCount;
  final int followingCount;
  final double traderRating;
  final int completedTrades;
  final String? profileImageUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.location,
    required this.joinDate,
    required this.isPremium,
    required this.photocardCount,
    required this.wishlistCount,
    required this.followersCount,
    required this.followingCount,
    required this.traderRating,
    required this.completedTrades,
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? username,
    String? email,
    String? bio,
    String? location,
    DateTime? joinDate,
    bool? isPremium,
    int? photocardCount,
    int? wishlistCount,
    int? followersCount,
    int? followingCount,
    double? traderRating,
    int? completedTrades,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      joinDate: joinDate ?? this.joinDate,
      isPremium: isPremium ?? this.isPremium,
      photocardCount: photocardCount ?? this.photocardCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      traderRating: traderRating ?? this.traderRating,
      completedTrades: completedTrades ?? this.completedTrades,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class Activity {
  final String id;
  final ActivityType type;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
  }
}

enum ActivityType {
  addedToCollection,
  addedToWishlist,
  completedTrade,
  receivedRating,
  createdAlbum,
  uploadedCard,
}
