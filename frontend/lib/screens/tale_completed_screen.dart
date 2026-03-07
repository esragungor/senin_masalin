import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/mock_data.dart';
import '../services/tale_service.dart';

/// Masal bittikten sonra çıkan "Tebrikler" ekranı.
class TaleCompletedScreen extends StatefulWidget {
  final Map<String, dynamic> storyData;

  const TaleCompletedScreen({super.key, required this.storyData});

  @override
  State<TaleCompletedScreen> createState() => _TaleCompletedScreenState();
}

class _TaleCompletedScreenState extends State<TaleCompletedScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final readyTales = MockData.readyTales.take(4).toList();

    String? coverUrl;
    final segments = widget.storyData['segments'];
    if (segments != null && segments is List && segments.isNotEmpty) {
      coverUrl = segments[0]['imageUrl'];
    }
    coverUrl ??= 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&h=400&fit=crop'; // fallback

    // storyId'yi hem 'storyId' hem 'id' anahtarından almayı dene
    final String? storyId = widget.storyData['storyId'] as String? ?? widget.storyData['id'] as String?;
    // Kaydedilmiş masaldan mı geliniyor (Sihirli Masallarım'dan)?
    final bool isSavedTale = widget.storyData['isSavedTale'] == true;

    // Hazır masallardan mı geliniyor?
    final bool isReadyTale = widget.storyData['isReadyTale'] == true;
    
    // Geri butonu metni ve yönlendirilecek sekme index'i
    final String backButtonText = isReadyTale ? 'Hazır Masallarım' : 'Sihirli Masallarım';
    final int backButtonIndex = isReadyTale ? 1 : 2; // 1: Hazır Masallar, 2: Kitaplık (Sihirli Masallar)

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Geri Butonu ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go('/home', extra: {'index': backButtonIndex}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF9947EB)),
                        const SizedBox(width: 4),
                        Text(backButtonText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9947EB))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ── Başlık ──────────────────────────────────────────────
              const Text(
                'Tebrikler, Kahraman!',

                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 32),

              // ── Kapak Görseli ────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9947EB).withAlpha(100),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      coverUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              // ── Alt Metin ───────────────────────────────────────────
              const Text(
                'Yaşasın! Bugünün puzzle parçasını\nkazandın!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // ── Birincil Aksiyon Butonu ─────────────────────────────
              if (isSavedTale) ...[
                // Kaydedilmiş masalı yeniden okuyorsa: Favorilerime Ekle
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (storyId == null) return;
                            setState(() => _isLoading = true);
                            try {
                              final newFav = !_isFavorite;
                              await TaleService.toggleFavorite(storyId, newFav);
                              if (mounted) {
                                setState(() {
                                  _isFavorite = newFav;
                                  _isLoading = false;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 20,
                          ),
                    label: Text(
                      _isFavorite ? 'Favorilerimden Çıkar' : 'Favorilerime Ekle',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFavorite ? Colors.redAccent : const Color(0xFF9947EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // İlk kez oluşturulan masal: Sihirli Masallarıma Ekle
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            try {
                              // Backend'e kaydet
                              await TaleService.saveTale(widget.storyData);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Masal k\u00fct\u00fcphanene eklendi! \u2728'),
                                    backgroundColor: Color(0xFF9947EB),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                // Kitaplık sekmesine git
                                context.go('/home', extra: {'index': 2});
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 20),
                    label: Text(
                      _isLoading ? 'Kaydediliyor...' : 'Sihirli Masallar\u0131ma Ekle',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9947EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text('Ana Sayfa',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Sırada Ne Var? ──────────────────────────────────────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sırada Ne Var?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 235,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: readyTales.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    return _ReadyTaleCard(data: readyTales[i]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ReadyTaleCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReadyTaleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final coverUrl = data['coverUrl'] ?? '';
    final timeAgo = data['timeAgo'] ?? '';

    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Kapak görseli ────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9947EB), Color(0xFF6B2DBF)],
                    ),
                  ),
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.book,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
                // Oynat ikonu sol alt
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF9947EB),
                      size: 20,
                    ),
                  ),
                ),
                // Favori ikonu sol üst
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(240),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: Color(0xFF8A94A6),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          Text(
            timeAgo,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A94A6)),
          ),
        ],
      ),
    );
  }
}
