import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class GetArticleUseCase implements UseCase<Article, String> {
  final NewsRepository repository;

  GetArticleUseCase(this.repository);

  @override
  Future<Either<Failure, Article>> call(String slug) async {
    return await repository.getArticle(slug);
  }
}
