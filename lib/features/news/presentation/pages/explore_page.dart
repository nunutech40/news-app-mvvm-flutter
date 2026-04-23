import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';
import 'package:news_app_mvvm/core/viewmodels/view_state.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/explore_viewmodel.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().loadAllSections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Jelajah Topik',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
            onPressed: () => context.read<ExploreViewModel>().loadAllSections(),
          ),
        ],
      ),
      body: Consumer<ExploreViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async {
              viewModel.loadAllSections();
              await Future.delayed(const Duration(seconds: 1)); // UX muter
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Scrollable dipaksa agar tetap bisa ditarik
              slivers: [
              SliverToBoxAdapter(
                child: _buildSection(
                  context,
                  title: '🚀 Top Teknologi',
                  state: viewModel.techState,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  context,
                  title: '💼 Sorotan Bisnis',
                  state: viewModel.businessState,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  context,
                  title: '⚽ Kabar Olahraga',
                  state: viewModel.sportsState,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required ViewState<List<Article>> state,
  }) {
    if (state.isLoading || state.isInitial) {
      // Tampilkan sekedar indikator loading tanpa label Title
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (state.isError || (state.data == null || state.data!.isEmpty)) {
      // Jika eror atau data kosong, sembunyikan section seutuhnya
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: _buildSectionContent(state.data!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(List<Article> articles) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (context, i) {
        final article = articles[i];
        return GestureDetector(
          onTap: () => context.push('/article/${article.slug}'),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusMd),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.displayImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: AppTheme.surfaceCard),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppTheme.surfaceElevated),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
