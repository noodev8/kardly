/**
 * API Service for Kardly Backend
 * Handles all HTTP requests to the Node.js server
 */

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // TODO: Update this with your actual server URL
  // For local development: 'http://localhost:3000'
  // For Android emulator: 'http://10.0.2.2:3000'
  // For iOS simulator: 'http://localhost:3000'
  // For production: 'https://your-production-url.com'
  static const String baseUrl = 'http://localhost:3000';
  
  /// Add a new photocard to the database
  /// 
  /// Parameters:
  /// - imagePath: Path to the image file
  /// - groupId: Optional UUID of the K-pop group
  /// - memberId: Optional UUID of the group member
  /// - albumId: Optional UUID of the album
  /// 
  /// Returns a Map with the response data or throws an exception
  static Future<Map<String, dynamic>> addPhotocard({
    required String imagePath,
    String? groupId,
    String? memberId,
    String? albumId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/add_photocard');
      final request = http.MultipartRequest('POST', uri);
      
      // Add image file
      final imageFile = await http.MultipartFile.fromPath(
        'image',
        imagePath,
      );
      request.files.add(imageFile);
      
      // Add optional fields
      if (groupId != null && groupId.isNotEmpty) {
        request.fields['group_id'] = groupId;
      }
      if (memberId != null && memberId.isNotEmpty) {
        request.fields['member_id'] = memberId;
      }
      if (albumId != null && albumId.isNotEmpty) {
        request.fields['album_id'] = albumId;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parse response
      final responseData = json.decode(response.body);
      
      // Check if request was successful
      if (response.statusCode == 201 && responseData['return_code'] == 'SUCCESS') {
        return responseData;
      } else {
        // Handle error response
        throw ApiException(
          returnCode: responseData['return_code'] ?? 'UNKNOWN_ERROR',
          message: responseData['message'] ?? 'An error occurred',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        returnCode: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  
  /// Health check endpoint
  static Future<bool> checkServerHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['return_code'] == 'SUCCESS';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String returnCode;
  final String message;
  final int statusCode;
  
  ApiException({
    required this.returnCode,
    required this.message,
    required this.statusCode,
  });
  
  @override
  String toString() => message;
  
  /// Get user-friendly error message
  String getUserFriendlyMessage() {
    switch (returnCode) {
      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.';
      case 'INVALID_GROUP':
        return 'The selected group does not exist.';
      case 'INVALID_MEMBER':
        return 'The selected member does not exist.';
      case 'INVALID_ALBUM':
        return 'The selected album does not exist.';
      case 'MEMBER_GROUP_MISMATCH':
        return 'The selected member does not belong to the chosen group.';
      case 'ALBUM_GROUP_MISMATCH':
        return 'The selected album does not belong to the chosen group.';
      case 'FILE_TOO_LARGE':
        return 'Image file is too large. Maximum size is 5MB.';
      case 'INVALID_FILE_TYPE':
        return 'Invalid file type. Please use JPG, PNG, or WEBP images.';
      case 'UPLOAD_FAILED':
        return 'Failed to upload image. Please try again.';
      case 'NETWORK_ERROR':
        return 'Cannot connect to server. Please check your internet connection.';
      case 'SERVER_ERROR':
        return 'Server error. Please try again later.';
      default:
        return message;
    }
  }
}

