import 'package:flutter/material.dart';

/// Masal sayfalarındaki görselleri göstermek için kullanılan kart bileşeni.
/// Görseli ve sağ alt köşesinde "Page X" etiketini içerir.
class TaleImageCard extends StatelessWidget {
  final String imageUrl;

  const TaleImageCard({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Resmin kenarlarında azıcık pay (beyaz çerçeve) efekti yaratmak için padding
      padding: const EdgeInsets.all(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Görsel ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imageUrl.startsWith('http')
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
                      color: const Color(0xFFEEEDFC),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: Color(0xFFB0BAC9), size: 48),
                      ),
                    ),
                  ),
          ),

        ],
      ),
    );
  }
}
