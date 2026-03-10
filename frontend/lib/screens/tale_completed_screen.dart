import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/mock_data.dart';
import '../services/tale_service.dart';
import '../services/local_favorite_service.dart';
import '../services/achievement_service.dart';
import '../features/ready_tales/ready_tales_registry.dart';
import '../features/ready_tales/widgets/ready_tale_card.dart';

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
  final Set<String> _favoriteIds = {};
  List<Map<String, dynamic>> _recommendedTales = [];

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _generateRecommendations();
    
    // Sayfa açılır açılmaz masalı okundu olarak işaretle (kullanıcı kaydetmese bile "Tebrikler" ekranını gördü)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storyId = widget.storyData['storyId'] as String? 
                   ?? widget.storyData['id'] as String?
                   ?? widget.storyData['title'] as String?
                   ?? 'unsaved_tale_${widget.storyData.hashCode}';
                   
      AchievementService.markTaleAsRead(storyId);
    });
  }

  void _generateRecommendations() {
    final bool isReadyTale = widget.storyData['isReadyTale'] == true;
    final String? currentTaleId = widget.storyData['storyId'] as String? ?? widget.storyData['id'] as String?;

    final allReady = ReadyTalesRegistry.allTales
        .map((t) => t.toStoryData())
        .where((t) => t['id'] != currentTaleId && t['storyId'] != currentTaleId)
        .toList();

    if (isReadyTale) {
      final currentCategory = widget.storyData['category'] as String?;
      
      var sameCategory = allReady.where((t) => t['category'] == currentCategory).toList()..shuffle();
      final takeSame = sameCategory.take(3).toList();
      _recommendedTales.addAll(takeSame);
      
      var otherCategory = allReady.where((t) => t['category'] != currentCategory).toList()..shuffle();
      final needed = 6 - _recommendedTales.length;
      final takeOther = otherCategory.take(needed).toList();
      _recommendedTales.addAll(takeOther);
    } else {
      allReady.shuffle();
      _recommendedTales = allReady.take(6).toList();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final storyId = widget.storyData['storyId'] as String? ?? widget.storyData['id'] as String?;
    final isReadyTale = widget.storyData['isReadyTale'] == true;
    
    // Geçerli okunan masalın durumunu kontrol et
    if (isReadyTale && storyId != null) {
      final isFav = await LocalFavoriteService.isFavorite(storyId);
      if (mounted) setState(() => _isFavorite = isFav);
    } else {
      final meta = widget.storyData['metadata'] as Map<String, dynamic>?;
      if (mounted) setState(() => _isFavorite = meta?['isFavorite'] == true);
    }

    // Sırada ne var kısmındaki önerilerin favori durumları için Local'den tüm favları çek
    final localFavs = await LocalFavoriteService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteIds.addAll(localFavs);
      });
    }
  }

  void _toggleFavoriteDynamic(String id) async {
    final formattedId = id.startsWith('ready_') ? id : 'ready_$id';
    final newFav = !_favoriteIds.contains(formattedId);
    
    // UI anında etkileşsin
    setState(() {
      if (newFav) {
        _favoriteIds.add(formattedId);
      } else {
        _favoriteIds.remove(formattedId);
      }
    });

    try {
      await LocalFavoriteService.toggleFavorite(formattedId);
    } catch (e) {
      // Hata durumunda geri al
      if (mounted) {
        setState(() {
          if (newFav) {
            _favoriteIds.remove(formattedId);
          } else {
            _favoriteIds.add(formattedId);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hazır masallardan mı geliniyor?
    final bool isReadyTale = widget.storyData['isReadyTale'] == true;

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
    
    // Geri butonu metni ve yönlendirilecek sekme index'i
    final String backButtonText = isReadyTale ? 'Hazır Masallarım' : 'Sihirli Masallarım';
    final int backButtonIndex = isReadyTale ? 1 : 2; // 1: Hazır Masallar, 2: Kitaplık (Sihirli Masallar)

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Geri Butonu ─────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          context.go('/home', extra: {'index': backButtonIndex});
                        },
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
                          child: coverUrl.startsWith('http')
                              ? Image.network(
                                  coverUrl,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
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
                                  AchievementService.markTaleAsRead(storyId);
                                  setState(() => _isLoading = true);
                                  try {
                                    bool newFavState;
                                    if (isReadyTale) {
                                      newFavState = await LocalFavoriteService.toggleFavorite(storyId);
                                    } else {
                                      newFavState = !_isFavorite;
                                      await TaleService.toggleFavorite(storyId, newFavState);
                                    }
                                    
                                    if (mounted) {
                                      setState(() {
                                        _isFavorite = newFavState;
                                        _isLoading = false;
                                      });
                                    }
                                  } catch (e) {
                                    debugPrint('Favori ekleme hatası: $e');
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Hata: $e')),
                                      );
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
                        onPressed: () {
                          context.go('/home');
                        },
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
                  ],
                ),
              ),

              // ── Sırada Ne Var? ──────────────────────────────────────
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
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
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedTales.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final dynId = _recommendedTales[i]['id'] as String;
                    final isFav = _favoriteIds.contains(dynId);
                    
                    // Asıl ReadyTale modeline geri dönüştür
                    final taleModel = ReadyTalesRegistry.allTales.firstWhere(
                      (t) => ('ready_${t.id}' == dynId || t.id == dynId),
                    );

                    return ReadyTaleCard(
                      tale: taleModel,
                      width: 150,
                      isFavorite: isFav,
                      onFavoriteToggle: () => _toggleFavoriteDynamic(dynId),
                      onTapOverride: () {
                        context.pushReplacement('/tale', extra: taleModel.toStoryData());
                      },
                    );
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


