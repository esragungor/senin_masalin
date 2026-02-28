import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Kayıt Ol sayfası için özel AppBar.
/// Ortada "Senin Masalın" yazar, solda geri ok vardır (Login'e döner).
class KayitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KayitAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.authAppBarBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      // Geri ok — Navigator.pop ile Login sayfasına döner
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.authAppBarTitle,
          size: 22,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
