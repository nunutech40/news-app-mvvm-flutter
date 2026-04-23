import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class GetNewsFeedUseCase implements UseCase<({Article? hero, List<Article> feed, int totalPages}), GetNewsFeedParams> {
  final NewsRepository repository;

  GetNewsFeedUseCase(this.repository);

  @override
  Future<Either<Failure, ({Article? hero, List<Article> feed, int totalPages})>> call(GetNewsFeedParams params) async {
    return await repository.getFeed(
      category: params.category,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
      includeHero: params.includeHero,
    );
  }
}

class GetNewsFeedParams extends Equatable {
  final String? category;
  final String? searchQuery;
  final int page;
  final int limit;
  final bool includeHero;

  const GetNewsFeedParams({
    this.category,
    this.searchQuery,
    this.page = 1,
    this.limit = 10,
    this.includeHero = true,
  });

  @override
  List<Object?> get props => [category, searchQuery, page, limit, includeHero];
}
