// lib/views/widgets/home_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../data/models/article_model.dart';
import 'news_card_widget.dart';
import '../../routes/route_name.dart';
import '../utils/helper.dart' as helper;


class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({super.key, required this.child, required this.index});

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    
    final delay = (widget.index * 100).clamp(0, 500);

    
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late HomeController _homeController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
    _tabController =
        TabController(length: _homeController.categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
        });
      }
      _homeController
          .onCategorySelected(_homeController.categories[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  // --- UI BARU DENGAN SLIVER DAN ANIMASI ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: _homeController,
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          int newIndex =
              controller.categories.indexOf(controller.selectedCategory);
          if (newIndex != -1 && newIndex != _tabController.index && !_tabController.indexIsChanging) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _tabController.animateTo(newIndex);
            });
          }
          return Scaffold(
            backgroundColor: theme.brightness == Brightness.light ? const Color.fromARGB(255, 199, 215, 239) : theme.scaffoldBackgroundColor,
            body: RefreshIndicator(
              onRefresh: () async => controller
                  .fetchArticlesByCategory(controller.selectedCategory),
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, theme, controller),
                  if (controller.isLoading && controller.articles.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.errorMessage != null && controller.articles.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                          child: Text('Gagal memuat berita.',
                              style:
                                  TextStyle(color: theme.colorScheme.error))),
                    )
                  else if (controller.articles.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('Tidak ada berita.')),
                    )
                  else
                    _buildSliverArticleList(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, ThemeData theme, HomeController controller) {
    return SliverAppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari berita di sini...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: theme.appBarTheme.foregroundColor?.withOpacity(0.7)),
              ),
              style: TextStyle(color: theme.appBarTheme.foregroundColor),
              onSubmitted: (query) => controller.searchArticles(query),
            )
          : const Text('Beritaku'),
      pinned: true,
      floating: true,
      snap: true,
      backgroundColor: theme.cardColor,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 2.0,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                controller.searchArticles('');
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: controller.categories
            .map((String category) => Tab(text: category))
            .toList(),
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.hintColor,
        indicatorColor: theme.colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  SliverList _buildSliverArticleList(HomeController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final article = controller.articles[index];
          bool isBookmarked = controller.isArticleBookmarked(article.url);
          return AnimatedListItem(
            index: index,
            child: NewsCardWidget(
              article: article,
              isBookmarked: isBookmarked,
              onBookmarkTap: () {
                controller.toggleBookmark(article);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isBookmarked
                      ? "'${article.title}' dihapus."
                      : "'${article.title}' disimpan."),
                ));
              },
            ),
          );
        },
        childCount: controller.articles.length,
      ),
    );
  }
}