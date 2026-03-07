import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/tale_service.dart';

/// "Masalı Oluştur" butonuna basıldıktan sonra gösterilen yükleme ekranı.
class TaleGeneratingScreen extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String? gender;
  final String? theme;
  final String? companion;
  final String? specialObject;
  final String? moral;

  const TaleGeneratingScreen({
    super.key,
    this.childName,
    this.childAge,
    this.gender,
    this.theme,
    this.companion,
    this.specialObject,
    this.moral,
  });

  @override
  State<TaleGeneratingScreen> createState() => _TaleGeneratingScreenState();
}

class _TaleGeneratingScreenState extends State<TaleGeneratingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  final List<String> _messages = [
    'Periler ve ejderhalar senin için\nsayfaları yazıyor, çok az kaldı!',
    'Sihirli kelimeler bir araya geliyor...',
    'Masalın neredeyse hazır, bekle!',
  ];
  int _msgIndex = 0;
  late Timer _msgTimer;

  Color get _bgColor {
    if (widget.gender == 'erkek') return const Color(0xFFEEF4FF);
    return const Color(0xFFFFF0F5);
  }

  @override
  void initState() {
    super.initState();

    // Nokta animasyonu (döngü)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Mesaj rotasyonu
    _msgTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _msgIndex = (_msgIndex + 1) % _messages.length;
        });
      }
    });

    // API ile masal üretmeye başla
    _generateTaleFromApi();
  }

  Future<void> _generateTaleFromApi() async {
    try {
      final result = await TaleService.generateTale(
        childName: widget.childName ?? 'Çocuk',
        childAge: widget.childAge ?? 5,
        gender: widget.gender ?? 'kız',
        theme: widget.theme ?? 'Orman',
        companion: widget.companion ?? 'Sevimli Köpek',
        specialObject: widget.specialObject ?? 'Harita',
        moral: widget.moral ?? 'Cesaret',
      );

      // Başarılı olursa, /tale ekranına yönlendir
      // storyId'yi yanında taşıyoruz ki favorileme ekranında kullanılabilsin
      if (mounted) {
        final storyContent = result['story'] as Map<String, dynamic>? ?? {};
        final storyId = result['storyId'] as String?;
        final combined = {
          ...storyContent,
          if (storyId != null) 'storyId': storyId,
        };
        context.go('/tale', extra: combined);
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        String displayError = 'Masal \u00fcretilirken bir hata olu\u015ftu.';
        
        if (errorStr.contains('LIMIT_REACHED')) {
          displayError = 'Masal limitine ula\u015ft\u0131n! L\u00fctfen yeni bir masal i\u00e7in eskilerden birini silin.';
        } else if (errorStr.contains('COOLDOWN')) {
          displayError = 'L\u00fctfen iki masal aras\u0131nda biraz bekleyin.';
        } else if (errorStr.contains('QUOTA_EXCEEDED')) {
          displayError = 'Sistem \u015fu an \u00e7ok yo\u011fun. L\u00fctfen 15 saniye sonra tekrar dene.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayError),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    _msgTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 80, 28, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // ── Beyaz kart ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Görsel ────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400&h=300&fit=crop',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
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
                          height: 200,
                          color: const Color(0xFFEEEDFC),
                          child: const Center(
                            child: Text('📖', style: TextStyle(fontSize: 64)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Başlık (animasyonlu nokta) ────────
                    AnimatedBuilder(
                      animation: _dotController,
                      builder: (context, _) {
                        final dots = '.' *
                            (_dotController.value * 3).ceil().clamp(1, 3);
                        return Text(
                          'Sihirli Masalınız\nHazırlanıyor$dots',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ── Alt mesaj (dönen) ─────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _messages[_msgIndex],
                        key: ValueKey(_msgIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A94A6),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
