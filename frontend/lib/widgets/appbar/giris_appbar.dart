import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Giriş ve Kayıt Ol sayfaları için özel AppBar.
/// Ortada "Senin Masalın" yazar, geri ok yoktur.
class GirisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GirisAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.authAppBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false, // Geri ok yok
      centerTitle: true,
      title: const Text(
        'Senin Masalın',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.authAppBarTitle,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
