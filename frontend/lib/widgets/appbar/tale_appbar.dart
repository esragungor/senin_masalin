import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Masal okuma ekranının AppBar'ı.
/// Geri butonu (sol), READING TIME + sayfa dot göstergesi (orta), Kaydet butonu (sağ).
class TaleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onBack;
  /// Hazır masallarda görünür; kahraman adını değiştirme diyalog'unu açar
  final VoidCallback? onNameChange;

  const TaleAppBar({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onBack,
    this.onNameChange,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Geri butonu ──────────────────────────────
            _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),

            // ── Orta: dot göstergesi ──────────────────────
              Row(
                children: List.generate(pageCount, (i) {
                  final active = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF9947EB)
                          : const Color(0xFFD8D0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

            // ── Sağ: İsim Değiştir veya boşluk ────────
            onNameChange != null
                ? GestureDetector(
                    onTap: onNameChange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 16, color: Color(0xFF9947EB)),
                          SizedBox(width: 4),
                          Text(
                            'İsim',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9947EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

/// Yuvarlak ikon butonu.
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF9947EB),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9947EB).withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? Colors.white,
        ),
      ),
    );
  }
}
