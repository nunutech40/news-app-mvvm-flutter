import 'package:flutter/material.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Jelajah Topik', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Explore Feature Coming Soon in MVVM!', style: TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}
