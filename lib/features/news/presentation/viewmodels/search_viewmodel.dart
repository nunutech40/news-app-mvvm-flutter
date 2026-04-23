import 'package:flutter/foundation.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';

class SearchViewModel extends ChangeNotifier {
  final GetNewsFeedUseCase _getNewsFeedUseCase;

  SearchViewModel({required GetNewsFeedUseCase getNewsFeedUseCase})
      : _getNewsFeedUseCase = getNewsFeedUseCase;

  ViewState<List<Article>> _searchState = ViewState.initial();
  ViewState<List<Article>> get searchState => _searchState;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  String _currentQuery = '';
  
  bool get isLoadingMore => _searchState.isLoading && _searchState.data != null && _searchState.data!.isNotEmpty;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchState = ViewState.initial();
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _currentQuery = query;
    _currentPage = 1;
    _hasReachedMax = false;
    
    _searchState = ViewState.loading();
    notifyListeners();

    final result = await _getNewsFeedUseCase(GetNewsFeedParams(
      searchQuery: _currentQuery,
      page: _currentPage,
      limit: 10,
      includeHero: false,
    ));

    result.fold(
      (failure) {
        _searchState = ViewState.error(failure.message);
        notifyListeners();
      },
      (data) {
        _hasReachedMax = data.feed.length < 10;
        _searchState = ViewState.success(data.feed);
        notifyListeners();
      },
    );
  }

  Future<void> loadMore() async {
    if (_hasReachedMax || _searchState.isLoading || _currentQuery.isEmpty) return;

    final currentData = _searchState.data ?? [];
    
    _searchState = ViewState.loading(currentData);
    notifyListeners();

    _currentPage++;

    final result = await _getNewsFeedUseCase(GetNewsFeedParams(
      searchQuery: _currentQuery,
      page: _currentPage,
      limit: 10,
      includeHero: false,
    ));

    result.fold(
      (failure) {
        // Rollback page and stop loading state, but keep data
        _currentPage--;
        _searchState = ViewState.success(currentData);
        // Optional: show error message via global alert or local state
        notifyListeners();
      },
      (data) {
        _hasReachedMax = data.feed.isEmpty || data.feed.length < 10;
        _searchState = ViewState.success([...currentData, ...data.feed]);
        notifyListeners();
      },
    );
  }
}
