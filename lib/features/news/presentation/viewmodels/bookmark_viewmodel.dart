import 'package:flutter/foundation.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_bookmarks_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/toggle_bookmark_usecase.dart';

class BookmarkViewModel extends ChangeNotifier {
  final GetBookmarksUseCase _getBookmarksUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;

  BookmarkViewModel({
    required GetBookmarksUseCase getBookmarksUseCase,
    required ToggleBookmarkUseCase toggleBookmarkUseCase,
  })  : _getBookmarksUseCase = getBookmarksUseCase,
        _toggleBookmarkUseCase = toggleBookmarkUseCase;

  ViewState<List<Article>> _bookmarksState = ViewState.initial();
  ViewState<List<Article>> get bookmarksState => _bookmarksState;

  Future<void> fetchBookmarks() async {
    _bookmarksState = ViewState.loading(_bookmarksState.data);
    notifyListeners();

    final result = await _getBookmarksUseCase(const NoParams());

    result.fold(
      (failure) {
        _bookmarksState = ViewState.error(failure.message, _bookmarksState.data);
        notifyListeners();
      },
      (bookmarks) {
        _bookmarksState = ViewState.success(bookmarks);
        notifyListeners();
      },
    );
  }

  Future<void> toggleBookmark(Article article) async {
    final result = await _toggleBookmarkUseCase(article);

    result.fold(
      (failure) {
        // Silently fail or you can add a temporary error message state
      },
      (_) {
        // Refresh bookmarks after toggle
        fetchBookmarks();
      },
    );
  }
}
