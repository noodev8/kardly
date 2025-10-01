import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<Photocard> _ownedCards = [];
  List<Photocard> _wishlistCards = [];
  List<Album> _albums = [];
  bool _isLoading = false;
  String? _error;

  List<Photocard> get ownedCards => _ownedCards;
  List<Photocard> get wishlistCards => _wishlistCards;
  List<Album> get albums => _albums;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOwnedCount => _ownedCards.length;
  int get totalWishlistCount => _wishlistCards.length;
  double get estimatedValue => _ownedCards.fold(0.0, (sum, card) => sum + card.estimatedValue);

  Future<void> loadCollection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load photocards from API
      final response = await ApiService.getPhotocards(limit: 100);
      final photocardsData = response['photocards'] as List<Map<String, dynamic>>;

      // Convert to Photocard objects
      _ownedCards = photocardsData.map((data) => Photocard.fromJson(data)).toList();

      // For now, wishlist is empty (we'll implement this later)
      _wishlistCards = [];
      _albums = [];
    } catch (e) {
      _error = e.toString();
      print('Error loading collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleOwned(String cardId) async {
    try {
      final response = await ApiService.toggleOwned(cardId);
      final isOwned = response['is_owned'] ?? false;

      // Update local state
      final cardIndex = _ownedCards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final card = _ownedCards[cardIndex];
        _ownedCards[cardIndex] = Photocard(
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
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling owned status: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(String cardId) async {
    try {
      final response = await ApiService.toggleWishlist(cardId);
      final isWishlisted = response['is_wishlisted'] ?? false;

      // Update local state
      final ownedIndex = _ownedCards.indexWhere((card) => card.id == cardId);
      if (ownedIndex != -1) {
        final card = _ownedCards[ownedIndex];
        _ownedCards[ownedIndex] = Photocard(
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

        // Move to/from wishlist
        if (isWishlisted && !_wishlistCards.any((c) => c.id == cardId)) {
          _wishlistCards.add(_ownedCards[ownedIndex]);
        } else if (!isWishlisted) {
          _wishlistCards.removeWhere((c) => c.id == cardId);
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling wishlist status: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Photocard> _generateMockCards(int count, bool isOwned) {
    final groups = ['NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY'];
    final members = ['Minji', 'Hanni', 'Danielle', 'Haerin', 'Hyein'];
    final albums = ['Get Up', 'NewJeans', 'OMG', 'Ditto', 'Hurt'];
    final rarities = ['Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'];

    return List.generate(count, (index) {
      return Photocard(
        id: '${isOwned ? 'owned' : 'wishlist'}_$index',
        groupName: groups[index % groups.length],
        memberName: members[index % members.length],
        albumName: albums[index % albums.length],
        rarity: rarities[index % rarities.length],
        estimatedValue: (index + 1) * 15.0,
        imageUrl: null,
        isOwned: isOwned,
        isWishlisted: !isOwned,
      );
    });
  }

  List<Album> _generateMockAlbums() {
    return [
      Album(
        id: 'album_1',
        title: 'NewJeans Collection',
        description: 'My favorite NewJeans photocards',
        cardCount: 25,
        totalPossible: 36,
        coverImageUrls: [],
      ),
      Album(
        id: 'album_2',
        title: 'BLACKPINK Favorites',
        description: 'Rare BLACKPINK cards',
        cardCount: 18,
        totalPossible: 45,
        coverImageUrls: [],
      ),
    ];
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
      isOwned: true, // All fetched cards are owned for now
      isWishlisted: false,
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
