import 'dart:convert';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class GoalService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Create a new goal
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.post(
        '/goals',
        data: goalData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {
        'success': true,
        'goal': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to create goal',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Fetch all goals for the current user
  Future<Map<String, dynamic>> fetchUserGoals() async {
    try {
      final token = await _storage.getToken();
      print('DEBUG GoalService: Token for fetch - ${token != null ? "EXISTS" : "NULL"}');
      
      if (token == null) {
        return {
          'success': false,
          'error': 'No token found - please login again',
        };
      }
      
      final response = await _dio.get(
        '/goals',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('DEBUG GoalService: Response type - ${response.data.runtimeType}');
      print('DEBUG GoalService: Response data - ${response.data}');

      // Handle both Map and String responses
      Map<String, dynamic> responseData;
      if (response.data is Map) {
        responseData = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseData = Map<String, dynamic>.from(jsonDecode(response.data));
      } else {
        throw Exception('Invalid response format');
      }

      // Check for error in response
      if (responseData.containsKey('error')) {
        return {'success': false, 'error': responseData['error']};
      }

      return {
        'success': true,
        'goals': responseData['goals'] ?? [],
      };
    } on DioException catch (e) {
      print('DEBUG GoalService: DioException - ${e.response?.statusCode} - ${e.response?.data}');
      String errorMsg = 'Failed to fetch goals';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data is Map 
              ? e.response!.data 
              : jsonDecode(e.response!.data);
          errorMsg = data['error'] ?? errorMsg;
        } catch (_) {}
      }
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      print('DEBUG GoalService: Exception - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Fetch a single goal by ID
  Future<Map<String, dynamic>> fetchGoalById(String id) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.get(
        '/goals/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {
        'success': true,
        'goal': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to fetch goal',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update an existing goal
  Future<Map<String, dynamic>> updateGoal(String id, Map<String, dynamic> goalData) async {
    try {
      final token = await _storage.getToken();
      
      final response = await _dio.patch(
        '/goals/$id',
        data: goalData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {
        'success': true,
        'goal': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to update goal',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete a goal
  Future<Map<String, dynamic>> deleteGoal(String id) async {
    try {
      final token = await _storage.getToken();
      
      await _dio.delete(
        '/goals/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {
        'success': true,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to delete goal',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
