import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:news_app_mvvm/core/theme/app_theme.dart';
import 'package:news_app_mvvm/core/utils/date_helper.dart';
import 'package:news_app_mvvm/core/widgets/empty_view.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/entities/category.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/news_feed_viewmodel.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<NewsFeedViewModel>();
      vm.fetchCategories();
      vm.fetchTrending();
      vm.fetchFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<NewsFeedViewModel>().loadMoreFeed();
    }
  }

  void _onCategorySelected(String slug) {
    context.read<NewsFeedViewModel>().fetchFeed(categorySlug: slug, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<NewsFeedViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceCard,
              onRefresh: () async {
                await Future.wait([
                  viewModel.fetchCategories(),
                  viewModel.fetchTrending(),
                  viewModel.fetchFeed(isRefresh: true),
                ]);
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // ── App Bar ────────────────────────────────────────────────────
                  const SliverToBoxAdapter(child: _NewsAppBar()),
                  
                  // ── Category Chips ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final state = viewModel.categoryState;
                        if (state.isLoading && state.data == null) {
                          return const _CategoryShimmer();
                        }
                        if (state.data != null) {
                          return _CategoryChips(
                            categories: state.data!,
                            selectedSlug: viewModel.selectedCategorySlug ?? '',
                            onSelected: _onCategorySelected,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // ── Trending (Independent API Call) ────────────
                  Builder(
                    builder: (context) {
                      final state = viewModel.trendingState;
                      if (state.isLoading && state.data == null) {
                        return const _TrendingShimmer();
                      }
                      if (state.data != null) {
                        return _TrendingSection(articles: state.data!.feed);
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  // ── Feed Content (Latest News vertical) ─────────
                  Builder(
                    builder: (context) {
                      final state = viewModel.feedState;
                      
                      if (state.isError && state.data == null) {
                        return SliverFillRemaining(
                          child: _ErrorView(
                            message: state.errorMessage ?? 'Error',
                            onRetry: () => viewModel.fetchFeed(isRefresh: true),
                          ),
                        );
                      }

                      if (state.isLoading && state.data == null) {
                        return const _FeedShimmer();
                      }
                      
                      if (state.data != null) {
                        return _FeedContent(
                          hero: state.data!.hero,
                          feed: state.data!.feed,
                          isLoadingMore: state.isLoading,
                          hasMore: true, // We could calculate this from totalPages
                        );
                      }
                      
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

class _NewsAppBar extends StatelessWidget {
  const _NewsAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'AURORA ',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            TextSpan(
              text: 'NEWS',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String selectedSlug;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final all = [
      const Category(id: 0, name: 'All', slug: '', description: '', isActive: true),
      ...categories,
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = all[i];
          final isSelected = cat.slug == selectedSlug;
          return GestureDetector(
            onTap: () => onSelected(cat.slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textMuted.withOpacity(0.2),
                ),
              ),
              child: Text(
                cat.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final List<Article> articles;
  const _TrendingSection({required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Trending Now',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _HorizontalCard(article: articles[i]),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FeedContent extends StatelessWidget {
  final Article? hero;
  final List<Article> feed;
  final bool isLoadingMore;
  final bool hasMore;

  const _FeedContent({
    this.hero,
    required this.feed,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (hero != null) ...[
          const SizedBox(height: 16),
          _HeroCard(article: hero!),
        ],
        const SizedBox(height: 20),
        _buildList(feed),
        if (isLoadingMore && feed.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildList(List<Article> articles) {
    if (articles.isEmpty) {
      return const Column(
        children: [
          SizedBox(height: 60),
          EmptyView(
            icon: Icons.article_outlined,
            message: 'Belum ada berita yang tersedia untuk saat ini.\nSilakan tarik ke bawah untuk memuat ulang.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 8),
          child: Text(
            'Latest Updates',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: AppTheme.textMuted.withOpacity(0.15),
                height: 1,
                thickness: 1,
              ),
            ),
            itemBuilder: (context, i) => _ListCard(article: articles[i]),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Article article;
  const _HeroCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article/${article.slug}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.surfaceCard),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceElevated),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20, right: 20, bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.categoryName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('By ${article.authorName}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                          const Spacer(),
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.white.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text('${article.readTimeMinutes}m read', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final Article article;
  const _HorizontalCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article/${article.slug}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
              child: SizedBox(
                height: 100, width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: article.displayImage,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.surfaceElevated),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceElevated),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryLight, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700, height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final Article article;
  const _ListCard({required this.article});

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
                    style: const TextStyle(
                      color: AppTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateHelper.timeAgo(article.publishedAt),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
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

// ── Shimmers ──────────────────────────────────────────────────────────────────
class _CategoryShimmer extends StatelessWidget {
  const _CategoryShimmer();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppTheme.surfaceCard,
          highlightColor: AppTheme.surfaceElevated,
          child: Container(
            width: 80, height: 36,
            decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class _TrendingShimmer extends StatelessWidget {
  const _TrendingShimmer();
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: AppTheme.surfaceCard, highlightColor: AppTheme.surfaceElevated,
              child: Container(width: 120, height: 20, color: AppTheme.surfaceCard),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppTheme.surfaceCard, highlightColor: AppTheme.surfaceElevated,
                child: Container(width: 160, height: 220, decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(AppTheme.radiusLg))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surfaceCard, highlightColor: AppTheme.surfaceElevated,
          child: Column(
            children: [
              Container(width: w - 40, height: 300, decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(AppTheme.radiusXl))),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 4,
                separatorBuilder: (_, __) => const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppTheme.surfaceCard, height: 1, thickness: 1)),
                itemBuilder: (_, __) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 60, height: 14, color: AppTheme.surfaceCard), const SizedBox(height: 8), Container(width: w * 0.5, height: 18, color: AppTheme.surfaceCard), const SizedBox(height: 4), Container(width: w * 0.4, height: 18, color: AppTheme.surfaceCard)])),
                    const SizedBox(width: 16),
                    Container(width: 90, height: 90, decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(AppTheme.radiusMd))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load news', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
