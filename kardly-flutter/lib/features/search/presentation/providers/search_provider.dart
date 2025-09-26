import 'package:flutter/material.dart';
import '../../../collection/presentation/providers/collection_provider.dart';

class SearchProvider extends ChangeNotifier {
  List<Photocard> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedGroup = 'All';
  String _selectedRarity = 'All';
  String _selectedSort = 'Newest';

  List<Photocard> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedGroup => _selectedGroup;
  String get selectedRarity => _selectedRarity;
  String get selectedSort => _selectedSort;

  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual search API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _searchResults = _generateMockSearchResults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGroupFilter(String group) {
    _selectedGroup = group;
    _applyFilters();
  }

  void setRarityFilter(String rarity) {
    _selectedRarity = rarity;
    _applyFilters();
  }

  void setSortOption(String sort) {
    _selectedSort = sort;
    _applyFilters();
  }

  void _applyFilters() {
    // TODO: Apply filters to search results
    notifyListeners();
  }

  List<Photocard> _generateMockSearchResults() {
    final groups = ['NewJeans', 'BLACKPINK', 'aespa', 'IVE', 'ITZY', 'TWICE', 'Red Velvet', 'NMIXX'];
    final members = ['Minji', 'Hanni', 'Danielle', 'Haerin', 'Hyein', 'Jisoo', 'Jennie', 'Rosé'];
    final albums = ['Get Up', 'NewJeans', 'OMG', 'Ditto', 'Born Pink', 'MY WORLD', 'LOVE DIVE'];
    final rarities = ['Common', 'Rare', 'Super Rare', 'Ultra Rare', 'Legendary'];

    return List.generate(247, (index) {
      return Photocard(
        id: 'search_$index',
        groupName: groups[index % groups.length],
        memberName: members[index % members.length],
        albumName: albums[index % albums.length],
        rarity: rarities[index % rarities.length],
        estimatedValue: (index + 1) * 12.0,
        imageUrl: null,
        isOwned: index % 4 == 0,
        isWishlisted: index % 3 == 0,
      );
    });
  }
}
