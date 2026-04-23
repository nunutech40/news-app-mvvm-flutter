import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/check_bookmark_status_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_article_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_bookmarks_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_categories_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/toggle_bookmark_usecase.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository mockRepository;
  late GetCategoriesUseCase getCategoriesUseCase;
  late GetNewsFeedUseCase getNewsFeedUseCase;
  late GetArticleUseCase getArticleUseCase;
  late GetBookmarksUseCase getBookmarksUseCase;
  late ToggleBookmarkUseCase toggleBookmarkUseCase;
  late CheckBookmarkStatusUseCase checkBookmarkStatusUseCase;

  final tArticle = const Article(
    id: 1, categoryId: 1, categoryName: '', authorName: '',
    title: 'Test', slug: 'test', description: '', imageUrl: '',
    readTimeMinutes: 1, status: '',
  );

  setUpAll(() {
    registerFallbackValue(tArticle);
  });

  setUp(() {
    mockRepository = MockNewsRepository();
    getCategoriesUseCase = GetCategoriesUseCase(mockRepository);
    getNewsFeedUseCase = GetNewsFeedUseCase(mockRepository);
    getArticleUseCase = GetArticleUseCase(mockRepository);
    getBookmarksUseCase = GetBookmarksUseCase(mockRepository);
    toggleBookmarkUseCase = ToggleBookmarkUseCase(mockRepository);
    checkBookmarkStatusUseCase = CheckBookmarkStatusUseCase(mockRepository);
  });

  test('GetCategoriesUseCase harus meneruskan pemanggilan ke repository', () async {
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => const Right(<Category>[]));

    final result = await getCategoriesUseCase(const NoParams());

    expect(result, const Right(<Category>[]));
    verify(() => mockRepository.getCategories()).called(1);
  });

  test('GetNewsFeedUseCase harus meneruskan pemanggilan ke repository', () async {
    final tRecord = (hero: null, feed: <Article>[], totalPages: 1);
    when(() => mockRepository.getFeed(
          category: any(named: 'category'),
          searchQuery: any(named: 'searchQuery'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          includeHero: any(named: 'includeHero'),
        )).thenAnswer((_) async => Right(tRecord));

    final result = await getNewsFeedUseCase(const GetNewsFeedParams());

    expect(result, Right(tRecord));
    verify(() => mockRepository.getFeed(
          category: null,
          searchQuery: null,
          page: 1,
          limit: 10,
          includeHero: true,
        )).called(1);
  });

  test('GetArticleUseCase harus meneruskan pemanggilan ke repository', () async {
    when(() => mockRepository.getArticle(any()))
        .thenAnswer((_) async => Right(tArticle));

    final result = await getArticleUseCase('test');

    expect(result, Right(tArticle));
    verify(() => mockRepository.getArticle('test')).called(1);
  });

  test('GetBookmarksUseCase harus meneruskan pemanggilan ke repository', () async {
    when(() => mockRepository.getBookmarks())
        .thenAnswer((_) async => const Right(<Article>[]));

    final result = await getBookmarksUseCase(const NoParams());

    expect(result, const Right(<Article>[]));
    verify(() => mockRepository.getBookmarks()).called(1);
  });

  test('ToggleBookmarkUseCase harus meneruskan pemanggilan ke repository', () async {
    when(() => mockRepository.toggleBookmark(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await toggleBookmarkUseCase(tArticle);

    expect(result, const Right(null));
    verify(() => mockRepository.toggleBookmark(tArticle)).called(1);
  });

  test('CheckBookmarkStatusUseCase harus meneruskan pemanggilan ke repository', () async {
    when(() => mockRepository.isBookmarked(any()))
        .thenAnswer((_) async => const Right(true));

    final result = await checkBookmarkStatusUseCase('test');

    expect(result, const Right(true));
    verify(() => mockRepository.isBookmarked('test')).called(1);
  });
}
