// lib/views/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:britaku/routes/route_name.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  
  int _calculateBottomAppBarIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String? currentRouteName = state.topRoute?.name;
    final String location = state.uri.toString();

    if (currentRouteName == RouteName.home ||
        location.startsWith('/${RouteName.home}')) {
      return 0;
    }
    if (currentRouteName == RouteName.bookmark ||
        location.startsWith('/${RouteName.bookmark}')) {
      return 1;
    }
    if (currentRouteName == RouteName.localArticles ||
        location.startsWith('/${RouteName.localArticles}')) {
      return 2;
    }
    // Rute baru untuk halaman tambah artikel
    if (currentRouteName == RouteName.addLocalArticle ||
        location.startsWith('/${RouteName.addLocalArticle}')) {
      return 3;
    }
    if (currentRouteName == RouteName.profile ||
        location.startsWith('/${RouteName.profile}')) {
      return 4;
    }
    
    // Default ke home
    return 0;
  }

  
  void _onBottomAppBarItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteName.home);
        break;
      case 1:
        context.goNamed(RouteName.bookmark);
        break;
      case 2:
        context.goNamed(RouteName.localArticles);
        break;
      case 3: // Item baru untuk tambah artikel
        context.goNamed(RouteName.addLocalArticle);
        break;
      case 4: // Profile sekarang di index 4
        context.goNamed(RouteName.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int bottomAppBarIndex = _calculateBottomAppBarIndex(context);

    return Scaffold(
      body: child,
      // --- FLOATING ACTION BUTTON DIHAPUS ---
      // floatingActionButton: ...
      // floatingActionButtonLocation: ...
      
      // --- BOTTOM APP BAR DIMODIFIKASI ---
      bottomNavigationBar: BottomAppBar(
        // Shape dan notch dihilangkan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_filled,
              label: 'Home',
              isSelected: bottomAppBarIndex == 0,
              onTap: () => _onBottomAppBarItemTapped(0, context),
            ),
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.bookmark_border_outlined,
              selectedIcon: Icons.bookmark_rounded,
              label: 'Bookmark',
              isSelected: bottomAppBarIndex == 1,
              onTap: () => _onBottomAppBarItemTapped(1, context),
            ),
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.article_outlined,
              selectedIcon: Icons.article,
              label: 'Local',
              isSelected: bottomAppBarIndex == 2,
              onTap: () => _onBottomAppBarItemTapped(2, context),
            ),
            // --- ITEM BARU UNTUK POST/TAMBAH ---
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.add_circle_outline_rounded,
              selectedIcon: Icons.add_circle_rounded,
              label: 'Tambah',
              isSelected: bottomAppBarIndex == 3,
              onTap: () => _onBottomAppBarItemTapped(3, context),
            ),
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              isSelected: bottomAppBarIndex == 4, // Index diubah menjadi 4
              onTap: () => _onBottomAppBarItemTapped(4, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem({
    required BuildContext context,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color itemColor = isSelected
        ? theme.bottomNavigationBarTheme.selectedItemColor ??
            theme.colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.hintColor;

    final double iconSize = 24.0;
    final double labelFontSize = 10.0;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isSelected ? (selectedIcon ?? icon) : icon,
                color: itemColor,
                size: iconSize,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: labelFontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}