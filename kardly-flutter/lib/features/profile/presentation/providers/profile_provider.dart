import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile([String? userId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getProfile();
      final profileData = response['profile'];

      _currentProfile = UserProfile.fromJson(profileData);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading profile: $e');
      // Fallback to mock data if API fails
      _currentProfile = _generateMockProfile();
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
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateProfile(
        username: username,
        bio: bio,
      );

      final updatedProfileData = response['profile'];

      // Update the current profile with the response data
      _currentProfile = _currentProfile!.copyWith(
        username: updatedProfileData['username'],
        bio: updatedProfileData['bio'],
        location: location ?? _currentProfile!.location, // Location not in API yet
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating profile: $e');
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? 'Unknown User',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      location: 'London, UK', // Default location since not in API yet
      joinDate: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isPremium: json['is_premium'] ?? false,
      photocardCount: stats['owned_count'] ?? 0,
      wishlistCount: stats['wishlist_count'] ?? 0,
      followersCount: 0, // Not implemented yet
      followingCount: 0, // Not implemented yet
      traderRating: 0.0, // Not implemented yet
      completedTrades: 0, // Not implemented yet
      profileImageUrl: null, // Not implemented yet
    );
  }

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


