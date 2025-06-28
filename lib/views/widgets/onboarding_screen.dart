// lib/views/widgets/onboarding_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// Class data UIData tetap sama
class OnboardingPageUIData {
  final String? foregroundImagePath;
  final String title;
  final String description;
  final Color dominantColor;

  OnboardingPageUIData({
    this.foregroundImagePath,
    required this.title,
    required this.description,
    required this.dominantColor,
  });
}

// Controller tetap sama, hanya data UI yang disesuaikan
class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageUIData> _pages = [
    OnboardingPageUIData(
      foregroundImagePath: 'assets/images/img intro 1.png',
      title: 'Teknologi Terkini',
      description:
          'Jelajahi kemajuan terbaru dan terobosan teknologi yang membentuk masa depan kita.',
      dominantColor: Colors.orange.shade700,
    ),
    OnboardingPageUIData(
      foregroundImagePath: 'assets/images/img intro 2.png',
      title: 'Kepribadian & Wawasan',
      description:
          'Pahami beragam kepribadian dan tingkatkan keterampilan interpersonal Anda secara efektif.',
      dominantColor: Colors.blue.shade700,
    ),
    OnboardingPageUIData(
      foregroundImagePath: 'assets/images/img intro 3.png',
      title: 'Wawasan Global',
      description:
          'Kembangkan pola pikir global untuk bernavigasi dan sukses di dunia yang saling terhubung.',
      dominantColor: Colors.green.shade700,
    ),
  ];

  List<OnboardingPageUIData> get pages => _pages;
  int get totalPages => _pages.length;
  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPageOrFinish(BuildContext context) {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteName.login);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

// --- TAMPILAN (UI) BARU DIMULAI DARI SINI ---
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Scaffold(
        body: Consumer<OnboardingController>(
          builder: (context, controller, child) {
            final currentPageData = controller.pages[controller.currentPage];
            final Color currentDominantColor = currentPageData.dominantColor;
            final bool isLastPage =
                controller.currentPage == controller.totalPages - 1;

            // Menggunakan Stack untuk latar belakang dan konten
            return Stack(
              fit: StackFit.expand,
              children: [
                // Latar Belakang Gambar Penuh
                Image.asset(
                  'assets/images/oren.jpg', // Ganti dengan gambar latar yang Anda suka
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.5),
                  colorBlendMode: BlendMode.darken,
                ),

                // Konten Onboarding di atas latar belakang
                Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: controller.totalPages,
                        itemBuilder: (context, index) {
                          final pageData = controller.pages[index];
                          // Widget page content tidak lagi membawa background
                          return _OnboardingPageContentWidget(
                            key: ValueKey('onboarding_page_$index'),
                            foregroundImagePath: pageData.foregroundImagePath,
                            title: pageData.title,
                            description: pageData.description,
                          );
                        },
                      ),
                    ),
                    // Indikator Halaman dan Tombol Navigasi
                    _buildBottomControls(
                      context,
                      controller,
                      currentDominantColor,
                      isLastPage,
                    ),
                  ],
                ),

                // Tombol "Skip" di pojok kanan atas
                if (!isLastPage)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: TextButton(
                      onPressed: () => context.goNamed(RouteName.login),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget untuk kontrol di bagian bawah (indikator & tombol)
  Widget _buildBottomControls(
    BuildContext context,
    OnboardingController controller,
    Color currentDominantColor,
    bool isLastPage,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.0,
        16.0,
        24.0,
        MediaQuery.of(context).padding.bottom + 32.0,
      ),
      child: Column(
        children: [
          // Indikator halaman
          _buildPageIndicator(controller, currentDominantColor),
          const SizedBox(height: 30.0),
          // Tombol Selanjutnya/Mulai
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => controller.nextPageOrFinish(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentDominantColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              child: Text(isLastPage ? 'Mulai Sekarang' : 'Selanjutnya'),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk indikator halaman (titik-titik)
  Widget _buildPageIndicator(
      OnboardingController controller, Color activeColor) {
    if (controller.totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: controller.currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: controller.currentPage == index
                ? activeColor
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}

// Widget ini sekarang hanya menampilkan konten (gambar depan, judul, deskripsi)
class _OnboardingPageContentWidget extends StatelessWidget {
  final String? foregroundImagePath;
  final String title;
  final String description;

  const _OnboardingPageContentWidget({
    super.key,
    this.foregroundImagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gambar Ilustrasi di tengah
        if (foregroundImagePath != null)
          Image.asset(
            foregroundImagePath!,
            height: screenHeight * 0.35,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                SizedBox(height: screenHeight * 0.35),
          ),
        SizedBox(height: screenHeight * 0.08),
        // Judul dan Deskripsi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: helper.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: helper.bold,
                  shadows: [
                    const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black87,
                        offset: Offset(1, 1))
                  ],
                ),
              ),
              helper.vsSmall,
              Text(
                description,
                textAlign: TextAlign.center,
                style: helper.subtitle1.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}