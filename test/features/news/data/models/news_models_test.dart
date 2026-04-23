import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_mvvm/features/news/data/models/news_models.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    const tCategoryModel = CategoryModel(
      id: 1,
      name: 'Technology',
      slug: 'technology',
      description: 'Tech news',
      isActive: true,
    );

    test('harus merupakan subclass dari Category entity', () {
      expect(tCategoryModel, isA<Category>());
    });

    test('fromJson harus mengembalikan model yang valid ketika data JSON komplit', () {
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Technology',
        'slug': 'technology',
        'description': 'Tech news',
        'is_active': true,
      };

      final result = CategoryModel.fromJson(jsonMap);

      expect(result, tCategoryModel);
    });

    test('fromJson harus menangani nilai null dengan default value yang benar', () {
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Technology',
        'slug': 'technology',
        // description dan is_active sengaja tidak dikirim
      };

      final result = CategoryModel.fromJson(jsonMap);

      expect(result.description, '');
      expect(result.isActive, true);
    });
  });

  group('ArticleModel', () {
    final tArticleModel = ArticleModel(
      id: 1,
      categoryId: 2,
      categoryName: 'Tech',
      authorName: 'John Doe',
      title: 'New AI Model',
      slug: 'new-ai-model',
      description: 'Description of AI',
      content: 'Full content of AI article',
      imageUrl: 'https://example.com/image.jpg',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      readTimeMinutes: 5,
      status: 'published',
      publishedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

    test('harus merupakan subclass dari Article entity', () {
      expect(tArticleModel, isA<Article>());
    });

    test('fromJson harus mengembalikan model yang valid ketika JSON komplit', () {
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'category_id': 2,
        'category_name': 'Tech',
        'author_name': 'John Doe',
        'title': 'New AI Model',
        'slug': 'new-ai-model',
        'description': 'Description of AI',
        'content': 'Full content of AI article',
        'image_url': 'https://example.com/image.jpg',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'read_time_minutes': 5,
        'status': 'published',
        'published_at': '2023-01-01T00:00:00.000Z',
      };

      final result = ArticleModel.fromJson(jsonMap);

      expect(result, tArticleModel);
    });

    test('fromJson harus menangani null values untuk field opsional', () {
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'category_id': 2,
        'title': 'New AI Model',
        'slug': 'new-ai-model',
        // field opsional lainnya kosong
      };

      final result = ArticleModel.fromJson(jsonMap);

      expect(result.categoryName, '');
      expect(result.authorName, '');
      expect(result.description, '');
      expect(result.content, isNull);
      expect(result.imageUrl, '');
      expect(result.thumbnailUrl, isNull);
      expect(result.readTimeMinutes, 1);
      expect(result.status, 'published');
      expect(result.publishedAt, isNull);
    });

    test('toJson harus mengembalikan Map yang sesuai', () {
      final result = tArticleModel.toJson();

      final expectedMap = {
        'id': 1,
        'category_id': 2,
        'category_name': 'Tech',
        'author_name': 'John Doe',
        'title': 'New AI Model',
        'slug': 'new-ai-model',
        'description': 'Description of AI',
        'content': 'Full content of AI article',
        'image_url': 'https://example.com/image.jpg',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'read_time_minutes': 5,
        'status': 'published',
        'published_at': '2023-01-01T00:00:00.000Z',
      };

      expect(result, expectedMap);
    });
  });
}
