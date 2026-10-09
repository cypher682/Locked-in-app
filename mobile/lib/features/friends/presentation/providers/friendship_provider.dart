import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/friendship/friendship_service.dart';

class FriendshipState {
  final bool isLoading;
  final List<dynamic> friends;
  final List<dynamic> pendingRequests;
  final String? error;

  FriendshipState({
    this.isLoading = false,
    this.friends = const [],
    this.pendingRequests = const [],
    this.error,
  });

  FriendshipState copyWith({
    bool? isLoading,
    List<dynamic>? friends,
    List<dynamic>? pendingRequests,
    String? error,
  }) {
    return FriendshipState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      error: error,
    );
  }
}

class FriendshipNotifier extends StateNotifier<FriendshipState> {
  final FriendshipService _friendshipService = FriendshipService();

  FriendshipNotifier() : super(FriendshipState());

  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _friendshipService.getFriends();

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        friends: result['friends'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future<void> loadPendingRequests() async {
    final result = await _friendshipService.getPendingRequests();

    if (result['success']) {
      state = state.copyWith(
        pendingRequests: result['requests'],
      );
    }
  }

  Future<bool> sendFriendRequest(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _friendshipService.sendFriendRequest(userId);

    state = state.copyWith(isLoading: false);

    if (result['success']) {
      return true;
    } else {
      state = state.copyWith(error: result['error']);
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String friendshipId) async {
    final result = await _friendshipService.acceptFriendRequest(friendshipId);

    if (result['success']) {
      // Reload friends and requests
      await loadFriends();
      await loadPendingRequests();
      return true;
    } else {
      state = state.copyWith(error: result['error']);
      return false;
    }
  }

  Future<bool> declineFriendRequest(String friendshipId) async {
    final result = await _friendshipService.declineFriendRequest(friendshipId);

    if (result['success']) {
      await loadPendingRequests();
      return true;
    } else {
      state = state.copyWith(error: result['error']);
      return false;
    }
  }

  Future<bool> removeFriend(String friendshipId) async {
    final result = await _friendshipService.removeFriend(friendshipId);

    if (result['success']) {
      await loadFriends();
      return true;
    } else {
      state = state.copyWith(error: result['error']);
      return false;
    }
  }
}

final friendshipProvider = StateNotifierProvider<FriendshipNotifier, FriendshipState>((ref) {
  return FriendshipNotifier();
});
