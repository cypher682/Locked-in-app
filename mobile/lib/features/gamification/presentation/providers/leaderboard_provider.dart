import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/leaderboard/leaderboard_service.dart';

class LeaderboardState {
  final bool isLoading;
  final List<dynamic> entries;
  final int? userRank;
  final String scope;
  final String? error;

  LeaderboardState({
    this.isLoading = false,
    this.entries = const [],
    this.userRank,
    this.scope = 'global',
    this.error,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    List<dynamic>? entries,
    int? userRank,
    String? scope,
    String? error,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      userRank: userRank ?? this.userRank,
      scope: scope ?? this.scope,
      error: error,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardService _leaderboardService = LeaderboardService();

  LeaderboardNotifier() : super(LeaderboardState());

  Future<void> loadLeaderboard({String scope = 'global'}) async {
    state = state.copyWith(isLoading: true, error: null, scope: scope);

    final result = await _leaderboardService.getLeaderboard(scope: scope);

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        entries: result['leaderboard'],
        userRank: result['userRank'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  void switchScope(String scope) {
    loadLeaderboard(scope: scope);
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
