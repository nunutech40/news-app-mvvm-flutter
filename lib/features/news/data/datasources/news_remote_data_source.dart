import 'package:news_app_mvvm/core/constants/api_constants.dart';
import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/features/news/data/models/news_models.dart';

abstract class NewsRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<Map<String, dynamic>> getFeed({
    String? category,
    String? searchQuery,
    int page = 1,
    int limit = 10,
    bool includeHero = true,
  });
  Future<ArticleModel> getArticle(String slug);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient apiClient;

  NewsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await apiClient.get(ApiConstants.newsCategories);
    final data = res['data'] as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> getFeed({
    String? category,
    String? searchQuery,
    int page = 1,
    int limit = 10,
    bool includeHero = true,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'include_hero': includeHero,
      if (category != null) 'category': category,
      if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
    };
    final res = await apiClient.get(
      ApiConstants.newsFeed,
      queryParameters: params,
    );
    return res['data'] as Map<String, dynamic>;
  }

  @override
  Future<ArticleModel> getArticle(String slug) async {
    final res = await apiClient.get('${ApiConstants.newsDetail}/$slug');
    return ArticleModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}
