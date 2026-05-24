import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../main.dart'; // sleepModeProvider
import '../animations/sleep_curtain_transition.dart';
import '../buttons/theme_toggle_button.dart';

/// Ana Sayfa AppBar'ı.
/// Her sekme için farklı başlık gösterir.
/// Riverpod ile gece/gündüz modunu güneş☀️/ay🌙 ikonu üzerinden toggle eder.
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int currentIndex;
  const HomeAppBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    final firstName = displayName.split(' ').first;
    final greeting = firstName.isNotEmpty ? firstName : 'Kaşif';
    final isDark = ref.watch(sleepModeProvider);

    // Her sekme için başlık verisi
    final tabTitles = [
      {'top': 'Sihirli Masallar', 'bottom': '$greeting! ✨'},
      {'top': 'Hazır Masal', 'bottom': 'Keşfet & Dinle 📚'},
      {'top': 'Masallarım', 'bottom': 'Sihirli Masallar ✨'},
      {'top': 'Favorilerim', 'bottom': 'En Sevdiklerin ❤️'},
      {'top': 'Profilim', 'bottom': 'Hesabın & Ayarlar ⚙️'},
    ];

    final title = tabTitles[currentIndex.clamp(0, tabTitles.length - 1)];

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight + 36,
      titleSpacing: 20,
      title: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title['top']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.offWhite 
                    : const Color(0xFF1A1A2E),
                height: 1.25,
              ),
            ),
            Text(
              title['bottom']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.pastelPurple 
                    : const Color(0xFF9947EB),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ── Güneş / Ay toggle ────────────────────────────
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 20),
          child: ThemeToggleButton(
            isDark: isDark,
            onTap: () {
              ref.read(sleepModeProvider.notifier).state = !isDark;
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 36);
}
