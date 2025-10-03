/// Provider for Add Photocard functionality
/// Manages state for adding new photocards to the database
library;

import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

class AddPhotocardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Map<String, dynamic>? _uploadedPhotocard;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get uploadedPhotocard => _uploadedPhotocard;

  /// Add a new photocard
  Future<bool> addPhotocard({
    required String imagePath,
    String? groupId,
    String? memberId,
    String? albumId,
    String allocationStatus = 'owned',
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    _uploadedPhotocard = null;
    notifyListeners();

    try {
      final response = await ApiService.addPhotocard(
        imagePath: imagePath,
        groupId: groupId,
        memberId: memberId,
        albumId: albumId,
      );

      _uploadedPhotocard = response;

      // Set allocation status if not 'unallocated'
      if (allocationStatus != 'unallocated' && response['photocard_id'] != null) {
        final photocardId = response['photocard_id'].toString();

        if (allocationStatus == 'owned') {
          await ApiService.toggleOwned(photocardId);
        } else if (allocationStatus == 'wishlist') {
          await ApiService.toggleWishlist(photocardId);
        }
      }

      _successMessage = response['message'] ?? 'Photocard added successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.getUserFriendlyMessage();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Reset the provider state
  void reset() {
    _isLoading = false;
    _error = null;
    _successMessage = null;
    _uploadedPhotocard = null;
    notifyListeners();
  }
}

