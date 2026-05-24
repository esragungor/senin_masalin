import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Masal sayfalarındaki görselleri göstermek için kullanılan kart bileşeni.
/// Görseli ve sağ alt köşesinde "Page X" etiketini içerir.
class TaleImageCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const TaleImageCard({
    super.key,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy.withAlpha(150) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: isDark ? Border.all(color: AppColors.pastelPurple.withAlpha(50), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Resmin kenarlarında azıcık pay (beyaz çerçeve) efekti yaratmak için padding
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Görsel ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: imageUrl.trim().isEmpty 
                  ? Container(
                      color: isDark ? AppColors.midnightNavy.withAlpha(50) : const Color(0xFFEEEDFC),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40),
                      ),
                    )
                  : imageUrl.startsWith('http')
                    ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFEEEDFC),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF9947EB),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEEEDFC),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: Color(0xFFB0BAC9), size: 48),
                      ),
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? AppColors.midnightNavy : const Color(0xFFEEEDFC),
                      child: Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: isDark ? AppColors.lavenderGrey : const Color(0xFFB0BAC9), size: 48),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
