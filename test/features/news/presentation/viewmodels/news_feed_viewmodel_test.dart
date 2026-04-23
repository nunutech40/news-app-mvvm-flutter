import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_categories_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/news_feed_viewmodel.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockGetNewsFeedUseCase extends Mock implements GetNewsFeedUseCase {}

void main() {
  late NewsFeedViewModel viewModel;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetNewsFeedUseCase mockGetNewsFeedUseCase;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetNewsFeedParams());
  });

  setUp(() {
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetNewsFeedUseCase = MockGetNewsFeedUseCase();
    viewModel = NewsFeedViewModel(
      getCategoriesUseCase: mockGetCategoriesUseCase,
      getNewsFeedUseCase: mockGetNewsFeedUseCase,
    );
  });

  group('fetchCategories', () {
    final tCategories = [const Category(id: 1, name: 'Tech', slug: 'tech', description: '', isActive: true)];

    test('harus mengubah state menjadi success ketika UseCase mengembalikan Right', () async {
      when(() => mockGetCategoriesUseCase(any()))
          .thenAnswer((_) async => Right(tCategories));

      expect(viewModel.categoryState.isInitial, true);

      final future = viewModel.fetchCategories();
      expect(viewModel.categoryState.isLoading, true);

      await future;

      expect(viewModel.categoryState.isSuccess, true);
      expect(viewModel.categoryState.data, tCategories);
    });

    test('harus mengubah state menjadi error ketika UseCase mengembalikan Left', () async {
      when(() => mockGetCategoriesUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server Error')));

      await viewModel.fetchCategories();

      expect(viewModel.categoryState.isError, true);
      expect(viewModel.categoryState.errorMessage, 'Server Error');
    });
  });

  group('fetchFeed', () {
    final tFeedData = (hero: null, feed: <Article>[], totalPages: 1);

    test('harus mengubah state menjadi success dan menyimpan data', () async {
      when(() => mockGetNewsFeedUseCase(any()))
          .thenAnswer((_) async => Right(tFeedData));

      await viewModel.fetchFeed(categorySlug: 'tech', isRefresh: true);

      expect(viewModel.selectedCategorySlug, 'tech');
      expect(viewModel.feedState.isSuccess, true);
      expect(viewModel.feedState.data?.totalPages, 1);
    });
  });
}
