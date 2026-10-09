import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  // Sign in with Email/Password
  Future<Map> signInWithEmail(String email, String password) async {
    try {
      // 1. Sign in to Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Get the Firebase ID Token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // 3. Send to Backend with Authorization Header
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'idToken': idToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      // Safely extract response data
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data type: ${response.data.runtimeType}');
      print('DEBUG: Response data: ${response.data}');
      
      // Handle response - could be Map or String depending on Content-Type
      Map<String, dynamic> responseData;
      if (response.data is Map) {
        responseData = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        // Parse JSON string if backend returned wrong Content-Type
        try {
          responseData = Map<String, dynamic>.from(
            jsonDecode(response.data as String)
          );
        } catch (_) {
          throw Exception('Failed to parse server response');
        }
      } else {
        throw Exception('Invalid response format: ${response.data.runtimeType}');
      }
      
      // Check for error response
      if (responseData.containsKey('error')) {
        return {
          'success': false,
          'error': responseData['error'],
        };
      }
      
      if (!responseData.containsKey('token') || !responseData.containsKey('user')) {
        throw Exception('Server response missing required fields');
      }

      return {
        'success': true,
        'token': responseData['token'],
        'user': responseData['user'],
      };
    } on DioException catch (e) {
      print('DEBUG: DioException status: ${e.response?.statusCode}');
      print('DEBUG: DioException data: ${e.response?.data}');
      print('DEBUG: DioException message: ${e.message}');
      
      String errorMsg = 'Network error';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMsg = e.response!.data['error'] ?? e.response!.data.toString();
        } else if (e.response!.data is String) {
          try {
            final parsed = jsonDecode(e.response!.data);
            errorMsg = parsed['error'] ?? e.response!.data;
          } catch (_) {
            errorMsg = e.response!.data;
          }
        }
      }
      
      return {
        'success': false,
        'error': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Sign up with Email/Password
  Future<Map> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      final response = await _apiService.post(
        '/auth/login',
        data: {
          'idToken': idToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response from server');
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
      
      if (!responseData.containsKey('token') || !responseData.containsKey('user')) {
        throw Exception('Server response missing required fields');
      }

      return {
        'success': true,
        'token': responseData['token'],
        'user': responseData['user'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Sign in with Google
  Future<Map> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) throw Exception('Failed to get ID token');

      final response = await _apiService.post(
        '/auth/login',
        data: {
          'idToken': idToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response from server');
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
      
      if (!responseData.containsKey('token') || !responseData.containsKey('user')) {
        throw Exception('Server response missing required fields');
      }

      return {
        'success': true,
        'token': responseData['token'],
        'user': responseData['user'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
