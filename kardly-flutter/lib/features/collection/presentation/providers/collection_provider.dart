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

  Future<void> loadCollection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Loading collection...');

      // Load owned cards
      final ownedResponse = await ApiService.getCollectionPhotocards(status: 'owned', limit: 100);
      debugPrint('Owned response: $ownedResponse');
      final ownedData = (ownedResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _ownedCards = ownedData.map((data) => Photocard.fromJson(data)).toList();
      debugPrint('Loaded ${_ownedCards.length} owned cards');

      // Load wishlist cards
      final wishlistResponse = await ApiService.getCollectionPhotocards(status: 'wishlist', limit: 100);
      debugPrint('Wishlist response: $wishlistResponse');
      final wishlistData = (wishlistResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _wishlistCards = wishlistData.map((data) => Photocard.fromJson(data)).toList();
      debugPrint('Loaded ${_wishlistCards.length} wishlist cards');

      // Load unallocated cards
      final unallocatedResponse = await ApiService.getCollectionPhotocards(status: 'unallocated', limit: 100);
      debugPrint('Unallocated response: $unallocatedResponse');
      final unallocatedData = (unallocatedResponse['photocards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _unallocatedCards = unallocatedData.map((data) => Photocard.fromJson(data)).toList();
      debugPrint('Loaded ${_unallocatedCards.length} unallocated cards');

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
        imageUrl: card.imageUrl,
        isOwned: isOwned,
        isWishlisted: card.isWishlisted,
        isFavorite: card.isFavorite,
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
        imageUrl: card.imageUrl,
        isOwned: card.isOwned,
        isWishlisted: isWishlisted,
        isFavorite: card.isFavorite,
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

  /// Toggle favorite status for a photocard
  Future<void> toggleFavorite(String cardId) async {
    try {
      final response = await ApiService.toggleFavorite(cardId);
      final isFavorite = response['is_favorite'] ?? false;

      // Find the card in all lists and update it
      final card = _findCardById(cardId);
      if (card == null) return;

      // Create updated card with new favorite status
      final updatedCard = Photocard(
        id: card.id,
        groupName: card.groupName,
        memberName: card.memberName,
        albumName: card.albumName,
        rarity: card.rarity,
        imageUrl: card.imageUrl,
        isOwned: card.isOwned,
        isWishlisted: card.isWishlisted,
        isFavorite: isFavorite,
      );

      // Update the card in all relevant lists
      _updateCardInLists(updatedCard);

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Helper method to update a card in all lists where it exists
  void _updateCardInLists(Photocard updatedCard) {
    // Update in owned cards
    final ownedIndex = _ownedCards.indexWhere((card) => card.id == updatedCard.id);
    if (ownedIndex != -1) {
      _ownedCards[ownedIndex] = updatedCard;
    }

    // Update in wishlist cards
    final wishlistIndex = _wishlistCards.indexWhere((card) => card.id == updatedCard.id);
    if (wishlistIndex != -1) {
      _wishlistCards[wishlistIndex] = updatedCard;
    }

    // Update in unallocated cards
    final unallocatedIndex = _unallocatedCards.indexWhere((card) => card.id == updatedCard.id);
    if (unallocatedIndex != -1) {
      _unallocatedCards[unallocatedIndex] = updatedCard;
    }
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
  final String? imageUrl;
  final bool isOwned;
  final bool isWishlisted;
  final bool isFavorite;

  Photocard({
    required this.id,
    required this.groupName,
    required this.memberName,
    required this.albumName,
    required this.rarity,
    this.imageUrl,
    required this.isOwned,
    required this.isWishlisted,
    required this.isFavorite,
  });

  factory Photocard.fromJson(Map<String, dynamic> json) {
    return Photocard(
      id: json['id'] ?? '',
      groupName: json['group_name'] ?? 'Unknown Group',
      memberName: json['member_stage_name'] ?? json['member_name'] ?? 'Unknown Member',
      albumName: json['album_title'] ?? 'Unknown Album',
      rarity: 'Common', // We don't have rarity in DB yet
      imageUrl: json['image_url'],
      isOwned: json['is_owned'] ?? false, // Get from collection status
      isWishlisted: json['is_wishlisted'] ?? false, // Get from collection status
      isFavorite: json['is_favorite'] ?? false, // Get from collection status
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
