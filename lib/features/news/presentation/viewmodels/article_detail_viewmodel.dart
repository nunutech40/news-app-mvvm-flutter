import 'package:flutter/foundation.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_article_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/check_bookmark_status_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/toggle_bookmark_usecase.dart';

class ArticleDetailViewModel extends ChangeNotifier {
  final GetArticleUseCase _getArticleUseCase;
  final CheckBookmarkStatusUseCase _checkBookmarkStatusUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;

  ArticleDetailViewModel({
    required GetArticleUseCase getArticleUseCase,
    required CheckBookmarkStatusUseCase checkBookmarkStatusUseCase,
    required ToggleBookmarkUseCase toggleBookmarkUseCase,
  })  : _getArticleUseCase = getArticleUseCase,
        _checkBookmarkStatusUseCase = checkBookmarkStatusUseCase,
        _toggleBookmarkUseCase = toggleBookmarkUseCase;

  ViewState<Article> _articleState = ViewState.initial();
  ViewState<Article> get articleState => _articleState;

  bool _isBookmarked = false;
  bool get isBookmarked => _isBookmarked;

  Future<void> fetchArticle(String slug) async {
    _articleState = ViewState.loading(_articleState.data);
    notifyListeners();

    final result = await _getArticleUseCase(slug);

    result.fold(
      (failure) {
        _articleState = ViewState.error(failure.message, _articleState.data);
        notifyListeners();
      },
      (article) {
        _articleState = ViewState.success(article);
        notifyListeners();
      },
    );
    
    await checkBookmarkStatus(slug);
  }

  Future<void> checkBookmarkStatus(String slug) async {
    final result = await _checkBookmarkStatusUseCase(slug);
    result.fold(
      (failure) {}, // Ignore error
      (status) {
        _isBookmarked = status;
        notifyListeners();
      },
    );
  }

  Future<void> toggleBookmark(Article article) async {
    // Optimistic UI Update
    _isBookmarked = !_isBookmarked;
    notifyListeners();

    final result = await _toggleBookmarkUseCase(article);
    result.fold(
      (failure) {
        // Rollback on failure
        _isBookmarked = !_isBookmarked;
        notifyListeners();
      },
      (_) {},
    );
  }
}
