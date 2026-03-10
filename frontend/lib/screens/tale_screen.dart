import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../widgets/appbar/tale_appbar.dart';
import '../widgets/appbar/tale_bottom_nav.dart';
import '../widgets/cards/tale_image_card.dart';
import '../services/tts_service.dart';
import '../services/achievement_service.dart';

/// Oluşturulan masalın okunduğu ekran.
class TaleScreen extends StatefulWidget {
  final Map<String, dynamic> storyData;

  const TaleScreen({
    super.key,
    required this.storyData,
  });

  @override
  State<TaleScreen> createState() => _TaleScreenState();
}

class _TaleScreenState extends State<TaleScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TTSService _ttsService = TTSService();
  late List<Map<String, dynamic>> _pages;

  // Hazır masallar için protagonist yönetimi
  bool get _isReadyTale => widget.storyData['isReadyTale'] == true;
  String _protagonistName = '';
  List<Map<String, dynamic>> _rawPages = [];

  StreamSubscription? _completionSubscription;
  bool _isAutoForwarding = false;

  @override
  void initState() {
    super.initState();
    final segments = widget.storyData['segments'] as List<dynamic>? ?? [];
    
    if (segments.isEmpty) {
      _pages = [
        {
          'imageUrl': 'https://images.unsplash.com/photo-1534447677768-be436bb09401',
          'text': 'Masal yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
        }
      ];
    } else {
      _pages = segments.map((s) => s as Map<String, dynamic>).toList();
    }

    // Hazır masalsa raw segment'leri ve protagonist adını sakla
    if (_isReadyTale) {
      _protagonistName = widget.storyData['protagonistName'] as String? ?? '';
      final rawSegs = widget.storyData['rawSegments'] as List<dynamic>? ?? [];
      _rawPages = rawSegs.map((s) => s as Map<String, dynamic>).toList();
    }

    _completionSubscription = _ttsService.onCompletion.listen((_) {
      _onAutoForward();
    });
    _ttsService.addListener(() {
      if (mounted) setState(() {});
    });

    // Eğer masal tek sayfalık ise (veya hatalı gelmişse) direkt okundu say
    if (_pages.length <= 1) {
      _markAsRead();
    }
  }

  void _markAsRead() {
    final storyId = widget.storyData['storyId'] as String? 
                 ?? widget.storyData['id'] as String?
                 ?? widget.storyData['title'] as String?
                 ?? 'unsaved_tale_${widget.storyData.hashCode}';
                 
    AchievementService.markTaleAsRead(storyId);
  }

  @override
  void dispose() {
    _completionSubscription?.cancel();
    _ttsService.stop();
    _pageController.dispose();
    super.dispose();
  }

  /// Hazır masallarda kahraman adını değiştir ve tüm sayfaları yenile
  void _changeProtagonist(String newName) {
    if (newName.trim().isEmpty) return;
    setState(() {
      _protagonistName = newName.trim();
      _pages = _rawPages.map((s) => {
        'text': (s['text'] as String? ?? '').replaceAll('{{PROTAGONIST}}', _protagonistName),
        'imageUrl': s['imageUrl'],
      }).toList();
    });
  }

  /// "İsim Değiştir" dialog'unu açar
  Future<void> _showChangeNameDialog() async {
    final controller = TextEditingController(text: _protagonistName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎤 Kahramanın Adı Ne Olsun?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Adı yaz...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9947EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (result != null) _changeProtagonist(result);
  }

  /// Ses bittiğinde otomatik geçiş tetiklenir
  Future<void> _onAutoForward() async {
    if (_isAutoForwarding) return;
    
    if (_currentPage < _pages.length - 1) {
      _isAutoForwarding = true;
      final targetPage = _currentPage + 1;

      // Sayfa animasyonunun bitmesini bekle
      await _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      // Yeni sayfa başladığında otomatik oku
      if (mounted && _currentPage == targetPage) {
        await _ttsService.speak(_pages[targetPage]['text'] ?? '');
      }
      
      _isAutoForwarding = false;
    } else {
      // Son sayfa bittiyse sadece UI'ı güncelle (buton Play'e dönsün)
      setState(() {});
    }
  }

  void _onPageChanged(int index) {
    // Manuel veya otomatik sayfa değişiminde mevcut index'i güncelle
    setState(() => _currentPage = index);

    // Kullanıcı son sayfaya geldiğinde okuma olarak say (masaldan erken çıksa bile)
    if (index >= _pages.length - 1) {
      _markAsRead();
    }
  }

  Future<bool> _showExitConfirmation() async {
    final bool isSavedTale = widget.storyData['isSavedTale'] == true;
    
    // Eğer masal zaten kütüphaneden açılmışsa, direkt çıkabilir
    if (isSavedTale) return true;

    _ttsService.stop();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Masaldan Çıkılsın mı?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Çıkış yapmak istediğinize emin misiniz? Masal kaydedilmediği için silinecektir.',
          style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Evet, Çık', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Sayfa 0'dan büyükse önceki sayfaya git
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return;
        }

        // Sayfa 0 ise çıkış onayı iste
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && mounted) {
           context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9FF),
        appBar: TaleAppBar(
          currentPage: _currentPage,
          pageCount: _pages.length,
          onNameChange: _isReadyTale ? _showChangeNameDialog : null,
          onBack: () async {
            // Sayfa 0'dan büyükse önceki sayfaya git
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              // Sayfa 0 ise çıkış onayı iste
              final shouldPop = await _showExitConfirmation();
              if (shouldPop && mounted) {
                context.go('/home');
              }
            }
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, i) => _TalePage(
                  pageIndex: i,
                  imageUrl: _pages[i]['imageUrl'] ?? '',
                  text: _pages[i]['text'] ?? '',
                ),
              ),
            ),
            TaleBottomNav(
              isLastPage: _currentPage == _pages.length - 1,
              isPlaying: _ttsService.isPlaying, // Durumu gönder
              onPlayAudio: () async {
                final textToRead = _pages[_currentPage]['text'] ?? '';
                if (_ttsService.isPlaying) {
                  await _ttsService.stop();
                } else {
                  await _ttsService.speak(textToRead);
                }
                // addListener zaten setState yapacağı için burada elzem değil ama kalsın
                setState(() {});
              },
              onNext: () async {
                // Kullanıcı ileri bastığında eğer ses çalıyorsa, sonraki sayfada da devam etsin
                final wasPlaying = _ttsService.isPlaying;
                
                if (_currentPage < _pages.length - 1) {
                  if (wasPlaying) await _ttsService.stop(); // Eski sesi durdur (race condition önlemek için)

                  await _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  
                  if (wasPlaying && mounted) {
                    // Yeni sayfayı okumaya başla
                    await _ttsService.speak(_pages[_currentPage]['text'] ?? '');
                  }
                } else {
                  await _ttsService.stop();
                  if (mounted) context.go('/tale/completed', extra: widget.storyData);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Masal içerik sayfası.
class _TalePage extends StatelessWidget {
  final int pageIndex;
  final String imageUrl;
  final String text;

  const _TalePage({
    required this.pageIndex,
    required this.imageUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
      child: Column(
        children: [
          // ── Görsel Kartı ──────────────────────────────
          TaleImageCard(
            imageUrl: imageUrl,
            onTap: () {
              if (imageUrl.isNotEmpty) {
                _showImageFullScreen(context, imageUrl);
              }
            },
          ),

          const SizedBox(height: 24),

          // ── Metin Kartı ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.7,
                color: Color(0xFF2D2D3A),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(BuildContext context, String imgUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10), // Ekrana biraz daha yayılsın
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Görsel
              InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imgUrl.startsWith('http')
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF9947EB),
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFEEEDFC),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_rounded, color: Color(0xFFB0BAC9), size: 48),
                            ),
                          ),
                        )
                      : Image.asset(
                          imgUrl,
                          fit: BoxFit.contain,
                        ),
                ),
              ),

              // Kapatma butonu (Sağ üst)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

