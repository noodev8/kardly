import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<Photocard> _ownedCards = [];
  List<Photocard> _wishlistCards = [];
  List<Photocard> _unallocatedCards = [];
  List<Album> _albums = [];
  bool _isLoading = false;
  String? _error;

  List<Photocard> get ownedCards => _ownedCards;
  List<Photocard> get wishlistCards => _wishlistCards;
  List<Photocard> get unallocatedCards => _unallocatedCards;
  List<Album> get albums => _albums;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOwnedCount => _ownedCards.length;
  int get totalWishlistCount => _wishlistCards.length;
  int get totalUnallocatedCount => _unallocatedCards.length;
  double get estimatedValue => _ownedCards.fold(0.0, (sum, card) => sum + card.estimatedValue);

  Future<void> loadCollection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load owned cards
      final ownedResponse = await ApiService.getCollectionPhotocards(status: 'owned', limit: 100);
      final ownedData = (ownedResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _ownedCards = ownedData.map((data) => Photocard.fromJson(data)).toList();

      // Load wishlist cards
      final wishlistResponse = await ApiService.getCollectionPhotocards(status: 'wishlist', limit: 100);
      final wishlistData = (wishlistResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _wishlistCards = wishlistData.map((data) => Photocard.fromJson(data)).toList();

      // Load unallocated cards
      final unallocatedResponse = await ApiService.getCollectionPhotocards(status: 'unallocated', limit: 100);
      final unallocatedData = (unallocatedResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _unallocatedCards = unallocatedData.map((data) => Photocard.fromJson(data)).toList();

      // For now, albums is empty (we'll implement this later)
      _albums = [];
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleOwned(String cardId) async {
    try {
      final response = await ApiService.toggleOwned(cardId);
      final isOwned = response['is_owned'] ?? false;

      // Find the card in any of the lists
      final Photocard? card = _findCardById(cardId);
      if (card == null) return;

      // Remove from current list
      _removeCardFromAllLists(cardId);

      // Create updated card
      final updatedCard = Photocard(
        id: card.id,
        groupName: card.groupName,
        memberName: card.memberName,
        albumName: card.albumName,
        rarity: card.rarity,
        estimatedValue: card.estimatedValue,
        imageUrl: card.imageUrl,
        isOwned: isOwned,
        isWishlisted: card.isWishlisted,
      );

      // Add to appropriate list
      if (isOwned) {
        _ownedCards.add(updatedCard);
      } else if (updatedCard.isWishlisted) {
        _wishlistCards.add(updatedCard);
      } else {
        _unallocatedCards.add(updatedCard);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling owned status: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(String cardId) async {
    try {
      final response = await ApiService.toggleWishlist(cardId);
      final isWishlisted = response['is_wishlisted'] ?? false;

      // Find the card in any of the lists
      final Photocard? card = _findCardById(cardId);
      if (card == null) return;

      // Remove from current list
      _removeCardFromAllLists(cardId);

      // Create updated card
      final updatedCard = Photocard(
        id: card.id,
        groupName: card.groupName,
        memberName: card.memberName,
        albumName: card.albumName,
        rarity: card.rarity,
        estimatedValue: card.estimatedValue,
        imageUrl: card.imageUrl,
        isOwned: card.isOwned,
        isWishlisted: isWishlisted,
      );

      // Add to appropriate list
      if (updatedCard.isOwned) {
        _ownedCards.add(updatedCard);
      } else if (isWishlisted) {
        _wishlistCards.add(updatedCard);
      } else {
        _unallocatedCards.add(updatedCard);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling wishlist status: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Helper method to find a card by ID in any list
  Photocard? _findCardById(String cardId) {
    // Check owned cards
    for (final card in _ownedCards) {
      if (card.id == cardId) return card;
    }
    // Check wishlist cards
    for (final card in _wishlistCards) {
      if (card.id == cardId) return card;
    }
    // Check unallocated cards
    for (final card in _unallocatedCards) {
      if (card.id == cardId) return card;
    }
    return null;
  }

  // Helper method to remove a card from all lists
  void _removeCardFromAllLists(String cardId) {
    _ownedCards.removeWhere((card) => card.id == cardId);
    _wishlistCards.removeWhere((card) => card.id == cardId);
    _unallocatedCards.removeWhere((card) => card.id == cardId);
  }


}

class Photocard {
  final String id;
  final String groupName;
  final String memberName;
  final String albumName;
  final String rarity;
  final double estimatedValue;
  final String? imageUrl;
  final bool isOwned;
  final bool isWishlisted;

  Photocard({
    required this.id,
    required this.groupName,
    required this.memberName,
    required this.albumName,
    required this.rarity,
    required this.estimatedValue,
    this.imageUrl,
    required this.isOwned,
    required this.isWishlisted,
  });

  factory Photocard.fromJson(Map<String, dynamic> json) {
    return Photocard(
      id: json['id'] ?? '',
      groupName: json['group_name'] ?? 'Unknown Group',
      memberName: json['member_stage_name'] ?? json['member_name'] ?? 'Unknown Member',
      albumName: json['album_title'] ?? 'Unknown Album',
      rarity: 'Common', // We don't have rarity in DB yet
      estimatedValue: 0.0, // We don't have value in DB yet
      imageUrl: json['image_url'],
      isOwned: json['is_owned'] ?? false, // Get from collection status
      isWishlisted: json['is_wishlisted'] ?? false, // Get from collection status
    );
  }
}

class Album {
  final String id;
  final String title;
  final String description;
  final int cardCount;
  final int totalPossible;
  final List<String> coverImageUrls;

  Album({
    required this.id,
    required this.title,
    required this.description,
    required this.cardCount,
    required this.totalPossible,
    required this.coverImageUrls,
  });

  double get completionPercentage => cardCount / totalPossible;
}
