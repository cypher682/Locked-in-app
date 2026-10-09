import 'dart:convert';
import 'package:dio/dio.dart';

/// Helper class for safe API response parsing
/// Handles cases where server returns String instead of Map
class ResponseParser {
  /// Parse response data to Map - handles both String and Map responses
  static Map<String, dynamic> parseData(dynamic data) {
    if (data == null) {
      throw Exception('Empty response from server');
    }
    
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    
    if (data is String) {
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map) {
          return Map<String, dynamic>.from(parsed);
        }
        throw Exception('Response is not a JSON object');
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    }
    
    throw Exception('Invalid response type: ${data.runtimeType}');
  }

  /// Extract error message from DioException
  static String extractError(DioException e, String defaultMessage) {
    if (e.response?.data == null) {
      return e.message ?? defaultMessage;
    }
    
    try {
      final data = parseData(e.response!.data);
      return data['error']?.toString() ?? defaultMessage;
    } catch (_) {
      if (e.response!.data is String) {
        return e.response!.data;
      }
      return defaultMessage;
    }
  }
}
