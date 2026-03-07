import 'package:flutter/material.dart';

/// Masal okuma ekranının alt navigasyon çubuğu.
/// Görseldeki gibi "Play Audio" butonu ve yuvarlak "Sonraki" butonu içerir.
class TaleBottomNav extends StatelessWidget {
  final VoidCallback onPlayAudio;
  final VoidCallback onNext;
  final bool isLastPage;
  final bool isPlaying;

  const TaleBottomNav({
    super.key,
    required this.onPlayAudio,
    required this.onNext,
    required this.isLastPage,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      child: Row(
        children: [
          // ── Play Audio Butonu ────────────────────────────────
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: onPlayAudio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9947EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isPlaying ? 'Sesi Durdur' : 'Sesli Oku',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // ── Sonraki / Tamamla Butonu ─────────────────────────
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: const Color(0xFF9947EB),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
