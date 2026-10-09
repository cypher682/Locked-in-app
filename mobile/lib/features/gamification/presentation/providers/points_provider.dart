import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/points/points_service.dart';

class PointsState {
  final bool isLoading;
  final int totalPoints;
  final List<dynamic> history;
  final String? error;

  PointsState({
    this.isLoading = false,
    this.totalPoints = 0,
    this.history = const [],
    this.error,
  });

  PointsState copyWith({
    bool? isLoading,
    int? totalPoints,
    List<dynamic>? history,
    String? error,
  }) {
    return PointsState(
      isLoading: isLoading ?? this.isLoading,
      totalPoints: totalPoints ?? this.totalPoints,
      history: history ?? this.history,
      error: error,
    );
  }
}

class PointsNotifier extends StateNotifier<PointsState> {
  final PointsService _pointsService = PointsService();

  PointsNotifier() : super(PointsState());

  Future<void> loadPoints() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _pointsService.getMyPoints();

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        totalPoints: result['totalPoints'],
        history: result['recentHistory'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  /// Add points locally (for optimistic UI after check-in)
  void addPoints(int points) {
    state = state.copyWith(totalPoints: state.totalPoints + points);
  }
}

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((ref) {
  return PointsNotifier();
});
