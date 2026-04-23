import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final NewsRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
