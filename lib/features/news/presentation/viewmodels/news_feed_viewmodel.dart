import 'package:flutter/foundation.dart' hide Category;
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_categories_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';

typedef FeedData = ({Article? hero, List<Article> feed, int totalPages});

class NewsFeedViewModel extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetNewsFeedUseCase _getNewsFeedUseCase;

  NewsFeedViewModel({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetNewsFeedUseCase getNewsFeedUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _getNewsFeedUseCase = getNewsFeedUseCase;

  // --- States ---
  ViewState<List<Category>> _categoryState = ViewState.initial();
  ViewState<FeedData> _feedState = ViewState.initial();
  
  // Trending state bisa menggunakan usecase yang sama dengan parameter berbeda (misal tanpa filter kategori)
  ViewState<FeedData> _trendingState = ViewState.initial();

  int _currentFeedPage = 1;
  String? _selectedCategorySlug;

  // --- Getters ---
  ViewState<List<Category>> get categoryState => _categoryState;
  ViewState<FeedData> get feedState => _feedState;
  ViewState<FeedData> get trendingState => _trendingState;
  String? get selectedCategorySlug => _selectedCategorySlug;

  // --- Actions ---

  Future<void> fetchCategories() async {
    _categoryState = ViewState.loading(_categoryState.data);
    notifyListeners();

    final result = await _getCategoriesUseCase(const NoParams());
    
    result.fold(
      (failure) {
        _categoryState = ViewState.error(failure.message, _categoryState.data);
        notifyListeners();
      },
      (categories) {
        _categoryState = ViewState.success(categories);
        notifyListeners();
      },
    );
  }

  Future<void> fetchFeed({String? categorySlug, bool isRefresh = false}) async {
    if (isRefresh) {
      _currentFeedPage = 1;
    }
    
    _selectedCategorySlug = categorySlug ?? _selectedCategorySlug;

    // Tampilkan loading, tapi tetap perlihatkan data lama jika ada
    _feedState = ViewState.loading(isRefresh ? null : _feedState.data);
    notifyListeners();

    final result = await _getNewsFeedUseCase(GetNewsFeedParams(
      category: _selectedCategorySlug,
      page: _currentFeedPage,
      limit: 10,
    ));

    result.fold(
      (failure) {
        _feedState = ViewState.error(failure.message, _feedState.data);
        notifyListeners();
      },
      (data) {
        if (isRefresh || _currentFeedPage == 1) {
          _feedState = ViewState.success(data);
        } else {
          // Pagination: gabungkan data lama dan baru
          final oldData = _feedState.data;
          final newFeedList = oldData != null ? [...oldData.feed, ...data.feed] : data.feed;
          _feedState = ViewState.success((
            hero: data.hero ?? oldData?.hero,
            feed: newFeedList,
            totalPages: data.totalPages,
          ));
        }
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreFeed() async {
    if (_feedState.isLoading || _feedState.data == null) return;
    if (_currentFeedPage >= _feedState.data!.totalPages) return;

    _currentFeedPage++;
    await fetchFeed(isRefresh: false);
  }

  Future<void> fetchTrending() async {
    _trendingState = ViewState.loading(_trendingState.data);
    notifyListeners();

    // Misalnya trending itu ambil feed tanpa kategori (global)
    final result = await _getNewsFeedUseCase(const GetNewsFeedParams(
      page: 1,
      limit: 5,
    ));

    result.fold(
      (failure) {
        _trendingState = ViewState.error(failure.message, _trendingState.data);
        notifyListeners();
      },
      (data) {
        _trendingState = ViewState.success(data);
        notifyListeners();
      },
    );
  }
}
