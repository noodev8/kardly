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
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Get all photocards with optional filters
  ///
  /// Parameters:
  /// - groupId: Optional UUID to filter by group
  /// - memberId: Optional UUID to filter by member
  /// - albumId: Optional UUID to filter by album
  /// - search: Optional search term
  /// - limit: Number of results to return (default: 50)
  /// - offset: Pagination offset (default: 0)
  ///
  /// Returns a Map with photocards array and metadata
  static Future<Map<String, dynamic>> getPhotocards({
    String? groupId,
    String? memberId,
    String? albumId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/photocards');

      // Build request body
      final Map<String, dynamic> body = {
        'limit': limit,
        'offset': offset,
      };

      if (groupId != null && groupId.isNotEmpty) {
        body['group_id'] = groupId;
      }
      if (memberId != null && memberId.isNotEmpty) {
        body['member_id'] = memberId;
      }
      if (albumId != null && albumId.isNotEmpty) {
        body['album_id'] = albumId;
      }
      if (search != null && search.isNotEmpty) {
        body['search'] = search;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'photocards': List<Map<String, dynamic>>.from(data['photocards'] ?? []),
          'count': data['count'] ?? 0,
          'total': data['total'] ?? 0,
          'limit': data['limit'] ?? limit,
          'offset': data['offset'] ?? offset,
        };
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to fetch photocards',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

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

  /// Get all groups or search by name
  static Future<List<Map<String, dynamic>>> getGroups({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/groups');

      // Build request body, only include search if it's not null
      final Map<String, dynamic> body = {};
      if (search != null && search.isNotEmpty) {
        body['search'] = search;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['groups'] ?? []);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to fetch groups',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

  /// Create a new group
  static Future<Map<String, dynamic>> createGroup({
    required String name,
    String? imageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/groups/create');

      // Build request body, only include non-null values
      final Map<String, dynamic> body = {'name': name};
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['image_url'] = imageUrl;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to create group',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

  /// Get all members or filter by group
  static Future<List<Map<String, dynamic>>> getMembers({
    String? groupId,
    String? search,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/members');

      // Build request body, only include non-null values
      final Map<String, dynamic> body = {};
      if (groupId != null && groupId.isNotEmpty) {
        body['group_id'] = groupId;
      }
      if (search != null && search.isNotEmpty) {
        body['search'] = search;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['members'] ?? []);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to fetch members',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

  /// Create a new member
  static Future<Map<String, dynamic>> createMember({
    required String groupId,
    required String name,
    String? stageName,
    String? imageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/members/create');

      // Build request body, only include non-null values
      final Map<String, dynamic> body = {
        'group_id': groupId,
        'name': name,
      };
      if (stageName != null && stageName.isNotEmpty) {
        body['stage_name'] = stageName;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['image_url'] = imageUrl;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to create member',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

  /// Get all albums or filter by group
  static Future<List<Map<String, dynamic>>> getAlbums({
    String? groupId,
    String? search,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/albums');

      // Build request body, only include non-null values
      final Map<String, dynamic> body = {};
      if (groupId != null && groupId.isNotEmpty) {
        body['group_id'] = groupId;
      }
      if (search != null && search.isNotEmpty) {
        body['search'] = search;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['albums'] ?? []);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to fetch albums',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
    }
  }

  /// Create a new album
  static Future<Map<String, dynamic>> createAlbum({
    required String groupId,
    required String title,
    String? coverImageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/albums/create');

      // Build request body, only include non-null values
      final Map<String, dynamic> body = {
        'group_id': groupId,
        'title': title,
      };
      if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
        body['cover_image_url'] = coverImageUrl;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw ApiException(
          returnCode: error['return_code'] ?? 'ERROR',
          message: error['message'] ?? 'Failed to create album',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        returnCode: 'NETWORK_ERROR',
        message: 'Cannot connect to server',
        statusCode: 0,
      );
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

