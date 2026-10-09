import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

// Constants
class CheckinConstants {
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 85;
  static const int maxNoteLength = 500;
}

class CheckinService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30), // Longer for photo uploads
    receiveTimeout: const Duration(seconds: 30),
  ));

  final StorageService _storage = StorageService();
  final ImagePicker _picker = ImagePicker();

  /// Pick photo from camera or gallery
  Future<File?> pickPhoto({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: CheckinConstants.maxImageWidth.toDouble(),
        maxHeight: CheckinConstants.maxImageHeight.toDouble(),
        imageQuality: CheckinConstants.imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Convert image file to base64
  Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final mimeType = 'image/$extension';
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    } catch (e) {
      return null;
    }
  }

  /// Create a new check-in
  Future<Map<String, dynamic>> createCheckin(Map<String, dynamic> checkinData) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.post(
        '/checkins',
        data: checkinData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'checkin': response.data};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to create check-in');
    } catch (e) {
      return _handleError(e, 'Failed to create check-in');
    }
  }

  /// Fetch check-ins for a specific goal
  Future<Map<String, dynamic>> fetchGoalCheckins(String goalId) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.get(
        '/goals/$goalId/checkins',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Handle both Map and String responses
      Map<String, dynamic> data;
      if (response.data is Map) {
        data = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        data = Map<String, dynamic>.from(jsonDecode(response.data));
      } else {
        throw Exception('Invalid response format');
      }

      return {'success': true, 'checkins': data['checkins'] ?? []};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to fetch check-ins');
    } catch (e) {
      return _handleError(e, 'Failed to fetch check-ins');
    }
  }

  /// Fetch all user check-ins
  Future<Map<String, dynamic>> fetchUserCheckins() async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.get(
        '/checkins',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response format');
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

      return {'success': true, 'checkins':data['checkins'] ?? []};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to fetch check-ins');
    } catch (e) {
      return _handleError(e, 'Failed to fetch check-ins');
    }
  }

  /// Get user streak data
  Future<Map<String, dynamic>> getUserStreak() async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.get(
        '/checkins/streak',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'streak': response.data};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to fetch streak');
    } catch (e) {
      return _handleError(e, 'Failed to fetch streak');
    }
  }

  /// Update a check-in
  Future<Map<String, dynamic>> updateCheckin(String id, Map<String, dynamic> checkinData) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.patch(
        '/checkins/$id',
        data: checkinData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'checkin': response.data};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to update check-in');
    } catch (e) {
      return _handleError(e, 'Failed to update check-in');
    }
  }

  /// Delete a check-in
  Future<Map<String, dynamic>> deleteCheckin(String id) async {
    try {
      final token = await _storage.getToken();
      
      await _dio.delete(
        '/checkins/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true};
    } on DioException catch (e) {
      return _handleError(e, 'Failed to delete check-in');
    } catch (e) {
      return _handleError(e, 'Failed to delete check-in');
    }
  }

  /// Centralized error handler
  Map<String, dynamic> _handleError(dynamic error, String defaultMessage) {
    String errorMessage = defaultMessage;
    
    if (error is DioException && error.response?.data != null) {
      errorMessage = error.response!.data['error'] ?? defaultMessage;
    } else if (error is Exception) {
      errorMessage = error.toString();
    }
    
    return {'success': false, 'error': errorMessage};
  }
}
