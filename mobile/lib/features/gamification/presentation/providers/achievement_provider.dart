import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/achievement/achievement_service.dart';

class AchievementState {
  final bool isLoading;
  final List<dynamic> allAchievements;
  final List<dynamic> unlockedAchievements;
  final String? error;

  AchievementState({
    this.isLoading = false,
    this.allAchievements = const [],
    this.unlockedAchievements = const [],
    this.error,
  });

  AchievementState copyWith({
    bool? isLoading,
    List<dynamic>? allAchievements,
    List<dynamic>? unlockedAchievements,
    String? error,
  }) {
    return AchievementState(
      isLoading: isLoading ?? this.isLoading,
      allAchievements: allAchievements ?? this.allAchievements,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      error: error,
    );
  }

  Set<String> get unlockedCodes => unlockedAchievements
      .map((a) => a['code']?.toString() ?? '')
      .where((c) => c.isNotEmpty)
      .toSet();
}

class AchievementNotifier extends StateNotifier<AchievementState> {
  final AchievementService _achievementService = AchievementService();

  AchievementNotifier() : super(AchievementState());

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, error: null);

    final allResult = await _achievementService.getAllAchievements();
    final myResult = await _achievementService.getMyAchievements();

    if (allResult['success'] && myResult['success']) {
      state = state.copyWith(
        isLoading: false,
        allAchievements: allResult['achievements'],
        unlockedAchievements: myResult['achievements'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: allResult['error'] ?? myResult['error'],
      );
    }
  }
}

final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  return AchievementNotifier();
});
