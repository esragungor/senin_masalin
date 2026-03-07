import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Ana Sayfa AppBar'ı.
/// Her sekme için farklı başlık gösterir.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  const HomeAppBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    final firstName = displayName.split(' ').first;
    final greeting = firstName.isNotEmpty ? firstName : 'Kaşif';
    final initial = greeting.isNotEmpty ? greeting[0].toUpperCase() : '?';
    final photoUrl = user?.photoURL;

    // Her sekme için başlık verisi
    final tabTitles = [
      {'top': 'Sihirli Masallar', 'bottom': '$greeting! ✨'},
      {'top': 'Hazır Masal', 'bottom': 'Keşfet & Dinle 📚'},
      {'top': 'Masallarım', 'bottom': 'Sihirli Masallar ✨'},
      {'top': 'Favorilerim', 'bottom': 'En Sevdiklerin ❤️'},
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
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 24),
          child: GestureDetector(
            onTap: () {
              // TODO: Profil sayfasına git
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF308CE8).withAlpha(40),
                border: Border.all(
                  color: const Color(0xFF308CE8).withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitial(initial),
                      )
                    : _buildInitial(initial),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF308CE8),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 36);
}
