import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../ready_tale_model.dart';
import '../screens/ready_tale_detail_screen.dart';

class ReadyTaleCard extends StatelessWidget {
  final ReadyTale tale;
  final double width;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTapOverride;

  const ReadyTaleCard({
    super.key,
    required this.tale,
    this.width = 170, // Default for Sihirli Masallarım
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = tale.title.replaceAll('{{PROTAGONIST}}', tale.defaultProtagonist);

    return GestureDetector(
      onTap: () {
        if (onTapOverride != null) {
          onTapOverride!();
        } else {
          // TaleScreen'e yönlendirmede toStoryData fonksiyonundan tam yararlan
          final storyData = tale.toStoryData();
          context.push('/tale', extra: storyData);
        }
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kapak görseli ────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: width, // Kare yapmak için
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).brightness == Brightness.dark 
                                ? AppColors.midnightNavy.withAlpha(200) 
                                : const Color(0xFF9947EB),
                            Theme.of(context).brightness == Brightness.dark 
                                ? AppColors.midnightNavy 
                                : const Color(0xFF6B2DBF),
                          ],
                        ),
                      ),
                    child: tale.coverAsset != null && tale.coverAsset!.trim().isNotEmpty
                        ? Image.asset(
                            tale.coverAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.book,
                              color: Colors.white54,
                              size: 50,
                            ),
                          )
                        : const Icon(
                            Icons.auto_stories,
                            color: Colors.white54,
                            size: 50,
                          ),
                  ),
                  
                  // Favori ikonu sol üst (her zaman görünür veya toggle varsa)
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(240),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: isFavorite
                                ? Colors.redAccent
                                : const Color(0xFF8A94A6),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              displayTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.offWhite 
                    : const Color(0xFF1A1A2E),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
    );
  }
}
