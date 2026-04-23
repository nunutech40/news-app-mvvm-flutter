import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app_mvvm/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app_mvvm/features/news/data/models/news_models.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({Article? hero, List<Article> feed, int totalPages})>> getFeed({
    String? category,
    String? searchQuery,
    int page = 1,
    int limit = 10,
    bool includeHero = true,
  }) async {
    try {
      final data = await remoteDataSource.getFeed(
        category: category,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
        includeHero: includeHero,
      );

      Article? hero;
      if (data['hero_article'] != null) {
        hero = ArticleModel.fromJson(data['hero_article'] as Map<String, dynamic>);
      }

      final feedRaw = data['feed_articles'] as List<dynamic>? ?? [];
      final feed = feedRaw
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      final totalPages = meta['total_pages'] as int? ?? 1;

      return Right((hero: hero, feed: feed, totalPages: totalPages));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Article>> getArticle(String slug) async {
    try {
      final result = await remoteDataSource.getArticle(slug);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getBookmarks() async {
    try {
      final result = await localDataSource.getBookmarks();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBookmark(Article article) async {
    try {
      await localDataSource.toggleBookmark(article);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(String slug) async {
    try {
      final result = await localDataSource.isBookmarked(slug);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
