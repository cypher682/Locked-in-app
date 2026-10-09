import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/social/social_service.dart';

class SocialState {
  final bool isLoading;
  final Map<String, bool> likedCheckins; // checkinId -> userLiked
  final Map<String, int> likeCounts; // checkinId -> count
  final String? error;

  SocialState({
    this.isLoading = false,
    this.likedCheckins = const {},
    this.likeCounts = const {},
    this.error,
  });

  SocialState copyWith({
    bool? isLoading,
    Map<String, bool>? likedCheckins,
    Map<String, int>? likeCounts,
    String? error,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      likedCheckins: likedCheckins ?? this.likedCheckins,
      likeCounts: likeCounts ?? this.likeCounts,
      error: error,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  final SocialService _socialService = SocialService();

  SocialNotifier() : super(SocialState());

  /// Toggle like on a check-in
  Future<bool> toggleLike(String checkinId) async {
    final currentlyLiked = state.likedCheckins[checkinId] ?? false;
    final currentCount = state.likeCounts[checkinId] ?? 0;

    // Optimistic update
    state = state.copyWith(
      likedCheckins: {...state.likedCheckins, checkinId: !currentlyLiked},
      likeCounts: {...state.likeCounts, checkinId: currentlyLiked ? currentCount - 1 : currentCount + 1},
    );

    final result = currentlyLiked
        ? await _socialService.unlikeCheckin(checkinId)
        : await _socialService.likeCheckin(checkinId);

    if (!result['success']) {
      // Revert on failure
      state = state.copyWith(
        likedCheckins: {...state.likedCheckins, checkinId: currentlyLiked},
        likeCounts: {...state.likeCounts, checkinId: currentCount},
        error: result['error'],
      );
      return false;
    }

    return true;
  }

  /// Load like status for a check-in
  Future<void> loadLikeStatus(String checkinId) async {
    final result = await _socialService.getCheckinLikes(checkinId);

    if (result['success']) {
      state = state.copyWith(
        likedCheckins: {...state.likedCheckins, checkinId: result['userLiked']},
        likeCounts: {...state.likeCounts, checkinId: result['count']},
      );
    }
  }

  /// Add a comment
  Future<Map<String, dynamic>?> addComment(String checkinId, String content) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _socialService.addComment(checkinId, content);

    state = state.copyWith(isLoading: false);

    if (result['success']) {
      return result['comment'];
    } else {
      state = state.copyWith(error: result['error']);
      return null;
    }
  }

  /// Get comments for a check-in
  Future<List<dynamic>> getComments(String checkinId) async {
    final result = await _socialService.getCheckinComments(checkinId);

    if (result['success']) {
      return result['comments'];
    }
    return [];
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    final result = await _socialService.deleteComment(commentId);
    return result['success'];
  }
}

final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  return SocialNotifier();
});
