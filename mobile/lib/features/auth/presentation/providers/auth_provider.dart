import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/storage/storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final Map? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthNotifier() : super(AuthState());

  Future signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.signInWithGoogle();
    
    if (result['success']) {
      await _storageService.saveToken(result['token']);
      await _storageService.saveUser(result['user']);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.signInWithEmail(email, password);
    
    if (result['success']) {
      await _storageService.saveToken(result['token']);
      await _storageService.saveUser(result['user']);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.signUpWithEmail(email, password);
    
    if (result['success']) {
      await _storageService.saveToken(result['token']);
      await _storageService.saveUser(result['user']);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future signOut() async {
    await _authService.signOut();
    await _storageService.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
