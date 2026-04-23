import 'package:flutter/material.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';

class NewsSearchPage extends StatelessWidget {
  const NewsSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Cari Berita', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Search Feature Coming Soon in MVVM!', style: TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}
