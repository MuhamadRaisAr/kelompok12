//----------------------------------------------------//

// ignore_for_file: deprecated_member_use

import 'package:britaku/views/widgets/bookmark_screen.dart';
import 'package:britaku/views/widgets/edit_profile_screen.dart';
import 'package:britaku/views/widgets/forgot_password_screen.dart';
import 'package:britaku/views/widgets/reset_password_screen.dart';
import 'package:britaku/views/widgets/home_screen.dart';
import 'package:britaku/views/widgets/news_detail_screen.dart';
import 'package:britaku/views/widgets/profile_screen.dart';
import 'package:britaku/views/widgets/register_screen.dart';
import 'package:britaku/views/widgets/splas_screen.dart';
import 'package:britaku/views/widgets/settings_screen.dart';
import 'package:britaku/views/widgets/widgets/change_password_screen.dart';
import 'package:britaku/views/widgets/add_local_article_screen.dart';
import 'package:britaku/views/widgets/local_articles_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- FIX: Import ditambahkan
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'views/widgets/onboarding_screen.dart';
import 'views/widgets/login_screen.dart';
import 'routes/route_name.dart';
import 'views/utils/helper.dart' as helper;
import 'data/models/article_model.dart';
import 'controllers/theme_controller.dart';
import 'views/widgets/main_scaffold.dart';
import 'package:britaku/controllers/local_article_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LocalArticleController()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: RouteName.splash,
  routes: <RouteBase>[
    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/introduction',
      name: RouteName.introduction,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: RouteName.login,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      name: RouteName.register,
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          name: RouteName.home,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/bookmark',
          name: RouteName.bookmark,
          builder: (BuildContext context, GoRouterState state) {
            return const BookmarkScreen();
          },
        ),
        GoRoute(
          path: '/add-local-article',
          name: RouteName.addLocalArticle,
          builder: (BuildContext context, GoRouterState state) {
            return const AddLocalArticleScreen();
          },
        ),
        GoRoute(
          path: '/local-articles',
          name: RouteName.localArticles,
          builder: (BuildContext context, GoRouterState state) {
            return const LocalArticlesScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          name: RouteName.profile,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'edit',
              name: RouteName.editProfile,
              builder: (BuildContext context, GoRouterState state) {
                final String? userId = state.extra as String?;

                if (userId != null) {
                  return EditProfileScreen(userId: userId);
                } else {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: const Center(
                      child: Text('User ID tidak valid untuk edit profil.'),
                    ),
                  );
                }
              },
            ),
            GoRoute(
              path: 'settings',
              name: RouteName.settings,
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'change-password',
                  name: RouteName.changePassword,
                  builder: (BuildContext context, GoRouterState state) {
                    return const ChangePasswordScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/article-detail',
      name: RouteName.articleDetail,
      builder: (BuildContext context, GoRouterState state) {
        final Article? article = state.extra as Article?;
        if (article != null) {
          return NewsDetailScreen(article: article);
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Artikel tidak ditemukan.')),
          );
        }
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteName.forgotPassword,
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: RouteName.resetPassword,
      builder: (BuildContext context, GoRouterState state) {
        final String? email = state.extra as String?;
        if (email != null) {
          return ResetPasswordScreen(email: email);
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Error")),
          body: const Center(
            child: Text("Email tidak valid untuk reset password."),
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan: ${state.error?.message ?? state.uri.toString()}',
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp.router(
      title: 'Beritaku',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: _buildThemeData(Brightness.light),
      darkTheme: _buildThemeData(Brightness.dark),
      themeMode: themeController.themeMode,
    );
  }

  ThemeData _buildThemeData(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // FIX: Menggunakan const untuk variabel yang nilainya konstan
    const Color primaryColor = helper.cPrimary;
    const Color accentColor = helper.cAccent;
    Color errorColor = helper.cError;

    final Color backgroundColor =
        isDark ? helper.cBackgroundDark : helper.cBackgroundLight;
    final Color cardColor = isDark ? helper.cCardDark : helper.cCardLight;
    final Color textPrimaryColor =
        isDark ? helper.cTextPrimaryDark : helper.cTextPrimaryLight;
    final Color textSecondaryColor =
        isDark ? helper.cTextSecondaryDark : helper.cTextSecondaryLight;

    final baseTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: cardColor,
        error: errorColor,
        onPrimary: helper.cWhite,
        onSecondary: helper.cBlack,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
        onError: helper.cWhite,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        titleTextStyle: helper.headline4.copyWith(
          color: textPrimaryColor,
          fontWeight: helper.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      textTheme: TextTheme(
        displayLarge: helper.headline1.copyWith(color: textPrimaryColor),
        displayMedium: helper.headline2.copyWith(color: textPrimaryColor),
        displaySmall: helper.headline3.copyWith(color: textPrimaryColor),
        headlineMedium: helper.headline4.copyWith(color: textPrimaryColor),
        titleLarge: helper.subtitle1.copyWith(
          color: textPrimaryColor,
          fontWeight: helper.bold,
        ),
        titleMedium: helper.subtitle1.copyWith(
            color: textPrimaryColor, fontWeight: helper.semibold),
        titleSmall:
            helper.subtitle2.copyWith(color: textPrimaryColor, fontWeight: helper.medium),
        bodyLarge: helper.subtitle1.copyWith(color: textPrimaryColor, height: 1.5),
        bodyMedium: helper.subtitle2.copyWith(color: textSecondaryColor, height: 1.5),
        labelLarge: helper.subtitle1.copyWith(
          color: helper.cWhite,
          fontWeight: helper.semibold,
        ),
        bodySmall: helper.caption.copyWith(color: textSecondaryColor),
        labelSmall: helper.overline.copyWith(color: textSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: helper.cWhite,
          textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1.0,
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : helper.cGrey.withOpacity(0.7),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
        labelStyle: helper.subtitle2.copyWith(color: textSecondaryColor),
        hintStyle: helper.subtitle2.copyWith(color: textSecondaryColor),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: cardColor,
        elevation: 8.0,
        shape: const CircularNotchedRectangle(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
      ),
    );
  }
}