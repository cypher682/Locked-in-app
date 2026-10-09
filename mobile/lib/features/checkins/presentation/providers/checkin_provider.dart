import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/checkin/checkin_service.dart';

class CheckinState {
  final bool isLoading;
  final List<Map<String, dynamic>> checkins;
  final Map<String, dynamic>? streak;
  final String? error;

  CheckinState({
    this.isLoading = false,
    this.checkins = const [],
    this.streak,
    this.error,
  });

  CheckinState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? checkins,
    Map<String, dynamic>? streak,
    String? error,
  }) {
    return CheckinState(
      isLoading: isLoading ?? this.isLoading,
      checkins: checkins ?? this.checkins,
      streak: streak ?? this.streak,
      error: error,
    );
  }
}

class CheckinNotifier extends StateNotifier<CheckinState> {
  final CheckinService _checkinService = CheckinService();

  CheckinNotifier() : super(CheckinState());

  /// Load all user check-ins
  Future<void> loadCheckins() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _checkinService.fetchUserCheckins();
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        checkins: List<Map<String, dynamic>>.from(result['checkins']),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  /// Load check-ins for a specific goal
  Future<void> loadGoalCheckins(String goalId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _checkinService.fetchGoalCheckins(goalId);
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        checkins: List<Map<String, dynamic>>.from(result['checkins']),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  /// Load user streak data
  Future<void> loadStreak() async {
    final result = await _checkinService.getUserStreak();
    
    if (result['success']) {
      state = state.copyWith(streak: result['streak']);
    }
  }

  /// Create a new check-in
  Future<bool> createCheckin(Map<String, dynamic> checkinData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _checkinService.createCheckin(checkinData);
    
    if (result['success']) {
      // Reload check-ins to get the updated list
      await loadCheckins();
      await loadStreak();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  /// Update a check-in
  Future<bool> updateCheckin(String id, Map<String, dynamic> checkinData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _checkinService.updateCheckin(id, checkinData);
    
    if (result['success']) {
      // Reload check-ins to get the updated list
      await loadCheckins();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  /// Delete a check-in
  Future<bool> deleteCheckin(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _checkinService.deleteCheckin(id);
    
    if (result['success']) {
      // Remove check-in from local state
      final updatedCheckins = state.checkins.where((c) => c['id'] != id).toList();
      state = state.copyWith(
        isLoading: false,
        checkins: updatedCheckins,
      );
      await loadStreak();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }
}

final checkinProvider = StateNotifierProvider<CheckinNotifier, CheckinState>((ref) {
  return CheckinNotifier();
});
