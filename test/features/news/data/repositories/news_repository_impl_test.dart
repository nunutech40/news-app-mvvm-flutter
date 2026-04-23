import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app_mvvm/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app_mvvm/features/news/data/models/news_models.dart';
import 'package:news_app_mvvm/features/news/data/repositories/news_repository_impl.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}
class MockNewsLocalDataSource extends Mock implements NewsLocalDataSource {}

void main() {
  late NewsRepositoryImpl repository;
  late MockNewsRemoteDataSource mockRemoteDataSource;
  late MockNewsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockNewsRemoteDataSource();
    mockLocalDataSource = MockNewsLocalDataSource();
    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getCategories', () {
    final tCategoryModels = [
      const CategoryModel(id: 1, name: 'Tech', slug: 'tech', description: '', isActive: true)
    ];

    test('harus mengembalikan daftar kategori (Right) ketika pemanggilan remote sukses', () async {
      when(() => mockRemoteDataSource.getCategories())
          .thenAnswer((_) async => tCategoryModels);

      final result = await repository.getCategories();

      expect(result, Right(tCategoryModels));
      verify(() => mockRemoteDataSource.getCategories()).called(1);
    });

    test('harus mengembalikan ServerFailure (Left) ketika terjadi ServerException', () async {
      when(() => mockRemoteDataSource.getCategories())
          .thenThrow(const ServerException(message: 'Server Down'));

      final result = await repository.getCategories();

      expect(result, const Left(ServerFailure(message: 'Server Down')));
    });

    test('harus mengembalikan NetworkFailure (Left) ketika terjadi NetworkException', () async {
      when(() => mockRemoteDataSource.getCategories())
          .thenThrow(const NetworkException(message: 'No Connection'));

      final result = await repository.getCategories();

      expect(result, const Left(NetworkFailure(message: 'No Connection')));
    });
  });

  group('getFeed', () {
    final tFeedMap = {
      'hero_article': null,
      'feed_articles': [],
      'meta': {'total_pages': 1}
    };

    test('harus mengembalikan format Record (Right) ketika remote sukses', () async {
      when(() => mockRemoteDataSource.getFeed(
            category: any(named: 'category'),
            searchQuery: any(named: 'searchQuery'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            includeHero: any(named: 'includeHero'),
          )).thenAnswer((_) async => tFeedMap);

      final result = await repository.getFeed();

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not be left'),
        (r) {
          expect(r.hero, isNull);
          expect(r.feed, isEmpty);
          expect(r.totalPages, 1);
        },
      );
    });

    test('harus mengembalikan Failure (Left) ketika terjadi Exception di remote', () async {
      when(() => mockRemoteDataSource.getFeed())
          .thenThrow(const ServerException(message: 'Error'));

      final result = await repository.getFeed();

      expect(result, const Left(ServerFailure(message: 'Error')));
    });
  });

  group('getBookmarks', () {
    final tArticles = [
      ArticleModel(
        id: 1, categoryId: 1, categoryName: '', authorName: '', title: '',
        slug: 'slug-1', description: '', imageUrl: '', readTimeMinutes: 1,
        status: '',
      )
    ];

    test('harus mengembalikan List<Article> (Right) ketika local sukses', () async {
      when(() => mockLocalDataSource.getBookmarks())
          .thenAnswer((_) async => tArticles);

      final result = await repository.getBookmarks();

      expect(result, Right(tArticles));
    });

    test('harus mengembalikan CacheFailure (Left) ketika local melempar CacheException', () async {
      when(() => mockLocalDataSource.getBookmarks())
          .thenThrow(const CacheException(message: 'Read error'));

      final result = await repository.getBookmarks();

      expect(result, const Left(CacheFailure(message: 'Read error')));
    });
  });
}
