import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/goal/goal_service.dart';

class GoalState {
  final bool isLoading;
  final List<Map<String, dynamic>> goals;
  final String? error;

  GoalState({
    this.isLoading = false,
    this.goals = const [],
    this.error,
  });

  GoalState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? goals,
    String? error,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: error,
    );
  }
}

class GoalNotifier extends StateNotifier<GoalState> {
  final GoalService _goalService = GoalService();

  GoalNotifier() : super(GoalState());

  /// Load all goals for the current user
  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _goalService.fetchUserGoals();
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        goals: List<Map<String, dynamic>>.from(result['goals']),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  /// Create a new goal
  Future<bool> createGoal(Map<String, dynamic> goalData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _goalService.createGoal(goalData);
    
    if (result['success']) {
      // Reload goals to get the updated list
      await loadGoals();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  /// Update an existing goal
  Future<bool> updateGoal(String id, Map<String, dynamic> goalData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _goalService.updateGoal(id, goalData);
    
    if (result['success']) {
      // Reload goals to get the updated list
      await loadGoals();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _goalService.deleteGoal(id);
    
    if (result['success']) {
      // Remove goal from local state
      final updatedGoals = state.goals.where((goal) => goal['id'] != id).toList();
      state = state.copyWith(
        isLoading: false,
        goals: updatedGoals,
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

  /// Filter goals by status
  List<Map<String, dynamic>> getGoalsByStatus(String status) {
    return state.goals.where((goal) => goal['status'] == status).toList();
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, GoalState>((ref) {
  return GoalNotifier();
});
