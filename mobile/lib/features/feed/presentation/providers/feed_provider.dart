import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/feed/feed_service.dart';

class FeedState {
  final bool isLoading;
  final List<dynamic> feedItems;
  final bool hasMore;
  final String? error;

  FeedState({
    this.isLoading = false,
    this.feedItems = const [],
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    bool? isLoading,
    List<dynamic>? feedItems,
    bool? hasMore,
    String? error,
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      feedItems: feedItems ?? this.feedItems,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedService _feedService = FeedService();

  FeedNotifier() : super(FeedState());

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      state = FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final offset = refresh ? 0 : state.feedItems.length;
    final result = await _feedService.getFeed(offset: offset);

    if (result['success']) {
      final newItems = result['feed'] as List<dynamic>;
      state = state.copyWith(
        isLoading: false,
        feedItems: refresh ? newItems : [...state.feedItems, ...newItems],
        hasMore: result['hasMore'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
    }
  }

  Future<void> refreshFeed() async {
    await loadFeed(refresh: true);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
