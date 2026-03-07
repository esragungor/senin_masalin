import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ready_tale_model.dart';
import '../screens/ready_tale_detail_screen.dart';

class ReadyTaleCard extends StatelessWidget {
  final ReadyTale tale;
  final double width;

  const ReadyTaleCard({
    super.key,
    required this.tale,
    this.width = 170, // Default for Sihirli Masallarım
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = tale.title.replaceAll('{{PROTAGONIST}}', tale.defaultProtagonist);

    return GestureDetector(
      onTap: () {
        // Karta tıklandığında direkt masala git
        // Ham segmentleri ({{PROTAGONIST}} içeren) ve varsayılan ismi ilet
        final storyData = {
          'id': tale.id,
          'title': displayTitle,
          'isSavedTale': true,
          'isReadyTale': true,
          'protagonistName': tale.defaultProtagonist,
          // Raw segmentler — TaleScreen içinde isim değiştirme için
          'rawSegments': tale.segments
              .map((s) => {'text': s.text, 'imageUrl': s.imageAsset})
              .toList(),
          'segments': tale.segments
              .map((s) => {
                    'text': s.text.replaceAll('{{PROTAGONIST}}', tale.defaultProtagonist),
                    'imageUrl': s.imageAsset,
                  })
              .toList(),
        };
        context.push('/tale', extra: storyData);
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kapak görseli ────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: width,
                height: width, // Kare yapmak için
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9947EB), Color(0xFF6B2DBF)],
                  ),
                ),
                child: tale.coverAsset != null
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
            ),

            const SizedBox(height: 8),

            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
    );
  }
}
