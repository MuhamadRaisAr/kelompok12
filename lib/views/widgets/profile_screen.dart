// lib/views/widgets/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/profile_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// Widget animasi yang sama seperti di halaman Home
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
      duration: const Duration(milliseconds: 400),
    );
    final delay = (widget.index * 100).clamp(0, 400);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// Nama kolom untuk konsistensi dengan controller
class _DbColumnNames {
  static const columnUsername = 'username';
  static const columnEmail = 'email';
  static const columnPhoneNumber = 'phone_number';
  static const columnAddress = 'address';
  static const columnCity = 'city';
  static const columnProfilePicturePath = 'profile_picture_path';
  static const columnId = '_id';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- UI BARU DENGAN GAYA MODERN DAN SELARAS ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.light
            ? const Color(0xFFF4F6F9)
            : theme.scaffoldBackgroundColor,
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.userData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(child: Text('Error: ${controller.errorMessage}'));
            }
            if (controller.userData == null) {
              return const Center(child: Text("Tidak dapat memuat profil."));
            }

            final userData = controller.userData!;

            return RefreshIndicator(
              onRefresh: controller.refreshProfile,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, theme, userData),
                  _buildProfileContent(context, theme, userData, controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Header Halaman Profil yang baru
  SliverAppBar _buildSliverAppBar(
      BuildContext context, ThemeData theme, Map<String, dynamic> userData) {
    String? profilePicPath =
        userData[_DbColumnNames.columnProfilePicturePath] as String?;

    return SliverAppBar(
      expandedHeight: 260.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          userData[_DbColumnNames.columnUsername] as String? ?? 'Username',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: ClipOval(
                      child: _buildProfileImage(profilePicPath),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userData[_DbColumnNames.columnEmail] as String? ?? 'email',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 40), // Spacer for title
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Konten Profil yang baru
  Widget _buildProfileContent(BuildContext context, ThemeData theme,
      Map<String, dynamic> userData, ProfileController controller) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const SizedBox(height: 24),
          // Kartu Informasi Akun
          AnimatedListItem(
            index: 0,
            child: _buildInfoCard(
              context: context,
              theme: theme,
              title: "Informasi Akun",
              children: [
                _buildInfoTile(
                  icon: Icons.phone_android_rounded,
                  label: "Nomor HP",
                  value:
                      userData[_DbColumnNames.columnPhoneNumber] as String? ?? "-",
                ),
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  label: "Alamat",
                  value: userData[_DbColumnNames.columnAddress] as String? ?? "-",
                ),
                _buildInfoTile(
                  icon: Icons.location_city_rounded,
                  label: "Kota",
                  value: userData[_DbColumnNames.columnCity] as String? ?? "-",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Kartu Pengaturan & Aksi
          AnimatedListItem(
            index: 1,
            child: _buildInfoCard(
              context: context,
              theme: theme,
              title: "Pengaturan",
              children: [
                _buildActionTile(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: "Edit Profil",
                  onTap: () async {
                    final String? userId = controller.userData?[_DbColumnNames.columnId];
                    if (userId != null) {
                      final bool? profileWasUpdated = await context.pushNamed<bool>(
                        RouteName.editProfile,
                        extra: userId,
                      );
                      if (profileWasUpdated == true && mounted) {
                        controller.refreshProfile();
                      }
                    }
                  },
                ),
                _buildActionTile(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: "Pengaturan Aplikasi",
                  onTap: () => context.pushNamed(RouteName.settings),
                ),
                _buildActionTile(
                  context: context,
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  color: theme.colorScheme.error,
                  onTap: () => controller.logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Widget helper untuk kartu
  Widget _buildInfoCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Widget helper untuk baris info
  Widget _buildInfoTile(
      {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        value.isNotEmpty ? value : "Belum diatur",
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: value.isNotEmpty
              ? theme.textTheme.bodyLarge?.color
              : theme.hintColor,
        ),
      ),
    );
  }

  // Widget helper untuk tombol aksi
  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final itemColor = color ?? theme.textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(title,
          style: theme.textTheme.titleMedium?.copyWith(color: itemColor)),
      trailing:
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: itemColor),
      onTap: onTap,
    );
  }

  // Widget helper untuk menampilkan gambar profil
  Widget _buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.person_rounded, size: 60, color: Colors.white);
    }
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (c, e, s) =>
              const Icon(Icons.person, size: 60, color: Colors.white));
    }
    if (kIsWeb) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }
    final imageFile = File(path);
    if (imageFile.existsSync()) {
      return Image.file(imageFile,
          fit: BoxFit.cover, width: 100, height: 100);
    }
    return const Icon(Icons.person_rounded, size: 60, color: Colors.white);
  }
}