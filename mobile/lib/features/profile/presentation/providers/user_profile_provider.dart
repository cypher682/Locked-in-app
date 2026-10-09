import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/user/user_profile_service.dart';

class UserProfileState {
  final bool isLoading;
  final Map<String, dynamic>? profile;
  final String? error;

  UserProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  UserProfileState copyWith({
    bool? isLoading,
    Map<String, dynamic>? profile,
    String? error,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _profileService = UserProfileService();

  UserProfileNotifier() : super(UserProfileState());

  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _profileService.getMyProfile();

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        profile: result['profile'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _profileService.updateProfile(profileData);

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        profile: result['profile'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final result = await _profileService.getUserProfile(userId);
    
    if (result['success']) {
      return result['profile'];
    }
    return null;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final result = await _profileService.searchUsers(query);
    
    if (result['success']) {
      return result['users'];
    }
    return [];
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier();
});
