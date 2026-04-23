import 'package:flutter/foundation.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';

class ExploreViewModel extends ChangeNotifier {
  final GetNewsFeedUseCase _getNewsFeedUseCase;

  ExploreViewModel({required GetNewsFeedUseCase getNewsFeedUseCase})
      : _getNewsFeedUseCase = getNewsFeedUseCase;

  ViewState<List<Article>> _techState = ViewState.initial();
  ViewState<List<Article>> get techState => _techState;

  ViewState<List<Article>> _businessState = ViewState.initial();
  ViewState<List<Article>> get businessState => _businessState;

  ViewState<List<Article>> _sportsState = ViewState.initial();
  ViewState<List<Article>> get sportsState => _sportsState;

  void loadAllSections() {
    _fetchTech();
    _fetchBusiness();
    _fetchSports();
  }

  Future<void> _fetchTech() async {
    _techState = ViewState.loading(_techState.data);
    notifyListeners();

    final result = await _getNewsFeedUseCase(const GetNewsFeedParams(
      category: 'technology',
      limit: 5,
      includeHero: false,
    ));

    // Delay untuk mensimulasikan efek cascade (UIUX) seperti di BLoC
    await Future.delayed(const Duration(milliseconds: 1500));

    result.fold(
      (failure) {
        _techState = ViewState.error(failure.message, _techState.data);
        notifyListeners();
      },
      (data) {
        _techState = ViewState.success(data.feed);
        notifyListeners();
      },
    );
  }

  Future<void> _fetchBusiness() async {
    _businessState = ViewState.loading(_businessState.data);
    notifyListeners();

    final result = await _getNewsFeedUseCase(const GetNewsFeedParams(
      category: 'business',
      limit: 5,
      includeHero: false,
    ));

    await Future.delayed(const Duration(milliseconds: 2500));

    result.fold(
      (failure) {
        _businessState = ViewState.error(failure.message, _businessState.data);
        notifyListeners();
      },
      (data) {
        _businessState = ViewState.success(data.feed);
        notifyListeners();
      },
    );
  }

  Future<void> _fetchSports() async {
    _sportsState = ViewState.loading(_sportsState.data);
    notifyListeners();

    final result = await _getNewsFeedUseCase(const GetNewsFeedParams(
      category: 'sports',
      limit: 5,
      includeHero: false,
    ));

    await Future.delayed(const Duration(milliseconds: 500));

    result.fold(
      (failure) {
        _sportsState = ViewState.error(failure.message, _sportsState.data);
        notifyListeners();
      },
      (data) {
        _sportsState = ViewState.success(data.feed);
        notifyListeners();
      },
    );
  }
}
