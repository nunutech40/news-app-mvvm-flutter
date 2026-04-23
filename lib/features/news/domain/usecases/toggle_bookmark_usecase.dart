import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class ToggleBookmarkUseCase implements UseCase<void, Article> {
  final NewsRepository repository;

  ToggleBookmarkUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Article params) async {
    return await repository.toggleBookmark(params);
  }
}
