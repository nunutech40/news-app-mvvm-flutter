import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, ({Article? hero, List<Article> feed, int totalPages})>> getFeed({
    String? category,
    String? searchQuery,
    int page = 1,
    int limit = 10,
    bool includeHero = true,
  });

  Future<Either<Failure, Article>> getArticle(String slug);

  // Local Bookmarks
  Future<Either<Failure, List<Article>>> getBookmarks();
  Future<Either<Failure, void>> toggleBookmark(Article article);
  Future<Either<Failure, bool>> isBookmarked(String slug);
}
