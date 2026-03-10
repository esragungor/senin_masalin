import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart'; // sleepModeProvider

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
      backgroundColor: const Color(0xFFF7F6F8),
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                height: 1.25,
              ),
            ),
            Text(
              title['bottom']!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9947EB),
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
          child: GestureDetector(
            onTap: () {
              ref.read(sleepModeProvider.notifier).state = !isDark;
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF9947EB).withAlpha(20)
                    : const Color(0xFFFFB300).withAlpha(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF9947EB).withAlpha(80)
                      : const Color(0xFFFFB300).withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isDark
                    ? const Icon(
                        Icons.nightlight_round,
                        key: ValueKey('moon'),
                        color: Color(0xFF9947EB),
                        size: 24,
                      )
                    : const Icon(
                        Icons.wb_sunny_rounded,
                        key: ValueKey('sun'),
                        color: Color(0xFFFFB300),
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 36);
}
