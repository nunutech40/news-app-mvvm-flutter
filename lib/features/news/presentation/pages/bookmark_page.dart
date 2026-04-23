import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';
import 'package:news_app_mvvm/core/utils/date_helper.dart';
import 'package:news_app_mvvm/core/widgets/empty_view.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/bookmark_viewmodel.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkViewModel>().fetchBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Tersimpan', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<BookmarkViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.bookmarksState;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (state.isError) {
            return Center(child: Text(state.errorMessage ?? 'Error', style: const TextStyle(color: Colors.red)));
          }

          final articles = state.data ?? [];
          
          if (articles.isEmpty) {
            return const EmptyView(
              icon: Icons.bookmark_border_rounded,
              title: 'Belum Ada Berita Tersimpan',
              message: 'Berita yang Anda simpan akan muncul di sini agar mudah dibaca kembali.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: articles.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppTheme.textMuted.withOpacity(0.15), height: 1, thickness: 1),
            ),
            itemBuilder: (context, i) {
              final article = articles[i];
              return _BookmarkCard(
                article: article,
                onRemove: () => viewModel.toggleBookmark(article),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Article article;
  final VoidCallback onRemove;

  const _BookmarkCard({required this.article, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article/${article.slug}'),
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.categoryName.toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        DateHelper.timeAgo(article.publishedAt),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(Icons.bookmark_remove_rounded, size: 20, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                width: 90, height: 90,
                child: CachedNetworkImage(
                  imageUrl: article.displayImage,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.surfaceCard),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceElevated),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
