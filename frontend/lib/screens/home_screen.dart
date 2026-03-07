import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/appbar/home_appbar.dart';
import '../widgets/appbar/home_bottom_nav.dart';
import '../core/constants/mock_data.dart';
import '../services/tale_service.dart';
import '../features/ready_tales/ready_tales_registry.dart';
import '../features/ready_tales/widgets/ready_tale_card.dart';

/// Ana Sayfa
class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late List<Map<String, dynamic>> _allTales;
  late List<Map<String, dynamic>> _predefinedTales;
  final Set<String> _favoriteIds = {};
  bool _isLoading = false; // Ekranı hemen aç; masallar arka planda yüklenir

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _allTales = MockData.myTales;
    _predefinedTales = List.from(MockData.readyTales);
    _loadMyTales();
  }

  Future<void> _loadMyTales() async {
    try {
      final tales = await TaleService.getMyTales();
      if (mounted) {
        // Backend'den gelen favorileri local set'e al
        final favIds = <String>{};
        for (final tale in tales) {
          final id = tale['id'] as String? ?? tale['storyId'] as String?;
          final meta = tale['metadata'] as Map<String, dynamic>?;
          if (id != null && meta != null && meta['isFavorite'] == true) {
            favIds.add(id);
          }
        }
        setState(() {
          _allTales = tales;
          MockData.myTales = tales;
          _favoriteIds.addAll(favIds);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Masallar y\u00fcklenemedI: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFavorite(String id) async {
    final newFav = !_favoriteIds.contains(id);
    // UI'ı hemen g\u00fcncelle
    setState(() {
      if (newFav) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
    });
    // Backend'e kaydet
    try {
      await TaleService.toggleFavorite(id, newFav);
    } catch (e) {
      // Hata olursa geri al
      if (mounted) {
        setState(() {
          if (newFav) {
            _favoriteIds.remove(id);
          } else {
            _favoriteIds.add(id);
          }
        });
      }
    }
  }

  void _deleteTale(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Masalı Sil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          content: const Text(
            'Bu masalı silmek istediğine emin misin? Bu işlem geri alınamaz.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Vazgeç',
                style: TextStyle(
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final taleId = _allTales[index]['id'];
                Navigator.of(context).pop();

                try {
                  // API'ye silme isteği at
                  await TaleService.deleteTale(taleId);
                  
                  // Başarılı olursa UI'dan kaldır
                  if (mounted) {
                    setState(() {
                      _allTales.removeAt(index);
                    });
                  }
                } catch (e) {
                  // Silme başarısız olursa kullanıcıya hata göster
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Silinirken hata oluştu: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Evet, Sil',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9947EB),
        ),
      );
    }

    if (_currentIndex == 1) {
      return _PredefinedTalesTab(
        favoriteIds: _favoriteIds,
        onFavoriteToggle: _toggleFavorite,
      );
    }
    if (_currentIndex == 2) {
      return _AllTalesTab(
        tales: _allTales,
        favoriteIds: _favoriteIds,
        onDelete: _deleteTale,
        onFavoriteToggle: _toggleFavorite,
      );
    }
    if (_currentIndex == 3) {
      final allTales = [..._allTales, ..._predefinedTales];
      final favoriteTales =
          allTales.where((t) => _favoriteIds.contains(t['id'])).toList();
      return _FavoritesTab(
        favoriteTales: favoriteTales,
        onFavoriteToggle: _toggleFavorite,
      );
    }

    // Varsayılan Ana Sayfa (0)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MagicHeroCard(
            onAction: () {
              if (_allTales.length >= 10) {
                _showLimitDialog();
              } else {
                context.push('/create');
              }
            },
          ),
          const SizedBox(height: 16),
          _RecentTalesSection(
            recentTales: _allTales.take(5).toList(),
            favoriteIds: _favoriteIds,
            onFavoriteToggle: _toggleFavorite,
            onSeeAll: () {
              setState(() => _currentIndex = 2);
            },
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('⚠️ ', style: TextStyle(fontSize: 24)),
            Text('Limit Doldu!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'En fazla 10 tane sihirli masal oluşturabilirsin. Yeni bir macera başlatmak için lütfen kütüphanenden en az bir masalı sil.',
          style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9947EB))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: HomeAppBar(currentIndex: _currentIndex),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                if (_allTales.length >= 10) {
                  _showLimitDialog();
                } else {
                  context.push('/create');
                }
              },
              backgroundColor: const Color(0xFF9947EB),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
            )
          : null,
      body: _buildBody(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HERO KART
// ────────────────────────────────────────────────────────────────────────────

/// AppBar altındaki "Sihirli Bir Macera Başlat" kartı.
class _MagicHeroCard extends StatelessWidget {
  final VoidCallback onAction;

  const _MagicHeroCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Mor daire + sihirli değnek ikonu ──────────
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF9947EB),
            ),
            child: const Icon(
              Icons.auto_fix_high_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(height: 12),

          // ── Başlık ────────────────────────────────────
          const Text(
            'Sihirli Bir Macera Başlat',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 6),

          // ── Alt yazı ──────────────────────────────────
          const Text(
            'Hayalindeki karakterleri seç\nve kendi masalını hemen oluştur!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A94A6),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // ── Yeni Masal Oluştur Butonu ─────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon: const Text('✨', style: TextStyle(fontSize: 18)),
              label: const Text(
                'Yeni Masal Oluştur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9947EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SON MASALLARIM BÖLÜMÜ
// ────────────────────────────────────────────────────────────────────────────

/// Sihirli masallar bölümü — önizleme için örnek veriler.
class _RecentTalesSection extends StatelessWidget {
  final VoidCallback onSeeAll;
  final List<Map<String, dynamic>> recentTales;
  final Set<String> favoriteIds;
  final Function(String) onFavoriteToggle;

  const _RecentTalesSection({
    required this.onSeeAll,
    required this.recentTales,
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık satırı ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sihirli Masallarım',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Tümünü Gör',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9947EB),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: recentTales.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final tale = recentTales[i];
              return _TaleCard(
                data: tale,
                isFavorite: favoriteIds.contains(tale['id']),
                onFavoriteToggle: () => onFavoriteToggle(tale['id']),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Hiç masal yokken boş durum.
class _EmptyTalesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEDFC), width: 1.5),
      ),
      child: const Column(
        children: [
          Text('📖', style: TextStyle(fontSize: 36)),
          SizedBox(height: 10),
          Text(
            'Henüz masalın yok',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'İlk masalını oluştur ve burada görün!',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A94A6)),
          ),
        ],
      ),
    );
  }
}

/// Tek bir masal kartı.
class _TaleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool showDelete;
  final VoidCallback? onDelete;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final double width;

  const _TaleCard({
    required this.data,
    this.showDelete = false,
    this.onDelete,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.width = 170, // Default for Sihirli Masallarım
  });

  @override
  Widget build(BuildContext context) {
    String title = 'İsimsiz Masal';
    String? coverUrl;

    if (data['content'] != null) {
      title = data['content']['title'] ?? title;
      final segments = data['content']['segments'];
      if (segments != null && segments is List && segments.isNotEmpty) {
        coverUrl = segments[0]['imageUrl'];
      }
    } else {
      title = data['title'] ?? title;
      coverUrl = data['coverUrl'];
      if (coverUrl == null && data['segments'] != null && data['segments'].isNotEmpty) {
        coverUrl = data['segments'][0]['imageUrl'];
      }
    }

    // Örnek veri string, Firestore verisi Timestamp olabilir
    String timeAgo = data['timeAgo'] as String? ?? '';
    if (timeAgo.isEmpty) {
      final createdAt = data['savedAt'] ?? data['createdAt'];
      if (createdAt != null) {
        // If it's a Map like {_seconds: ..., _nanoseconds: ...} (which is how Firestore timestamps look when serialized via JSON)
        if (createdAt is Map<String, dynamic> && createdAt.containsKey('_seconds')) {
          final seconds = createdAt['_seconds'] as int;
          final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          final diff = DateTime.now().difference(date);
          if (diff.inDays > 0) {
            timeAgo = '${diff.inDays} gün önce';
          } else if (diff.inHours > 0) {
            timeAgo = '${diff.inHours} saat önce';
          } else {
            timeAgo = 'Az önce';
          }
        } else if (createdAt is String) {
           final date = DateTime.tryParse(createdAt);
           if (date != null) {
              final diff = DateTime.now().difference(date);
              if (diff.inDays > 0) {
                timeAgo = '${diff.inDays} gün önce';
              } else if (diff.inHours > 0) {
                timeAgo = '${diff.inHours} saat önce';
              } else {
                timeAgo = 'Az önce';
              }
           }
        }
      }
    }

    // Backend'den gelen veriyi TaleScreen'in beklediği formata çevir
    Map<String, dynamic> storyDataForScreen;
    if (data['content'] != null) {
      final storyId = data['id'] ?? data['storyId'];
      storyDataForScreen = {
        'title': data['content']['title'],
        'segments': data['content']['segments'],
        if (storyId != null) 'storyId': storyId,
        'isSavedTale': true, // Kaydedilmiş masaldan gelindiğini işaretle
      };
    } else {
      storyDataForScreen = {...data, 'isSavedTale': true};
    }

    return GestureDetector(
      onTap: () => context.push('/tale', extra: storyDataForScreen),
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9947EB), Color(0xFF6B2DBF)],
                    ),
                  ),
                  child: coverUrl != null
                      ? Image.network(
                          coverUrl,
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
                // Favori ikonu sol üst (her zaman)
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

                // Sil ikonu sağ üst
                if (showDelete)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(240),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
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
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TÜM MASALLAR SEKMSİ
// ────────────────────────────────────────────────────────────────────────────

/// Alt gezinme çubuğunda "Sihirli Masallar" seçildiğinde gösterilen sayfa.
class _AllTalesTab extends StatelessWidget {
  final List<Map<String, dynamic>> tales;
  final Function(int) onDelete;
  final Set<String> favoriteIds;
  final Function(String) onFavoriteToggle;

  const _AllTalesTab({
    required this.tales,
    required this.onDelete,
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tales.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _EmptyTalesState(),
        ),
      );
    }

    final int maxTales = 10;
    final int remaining = (maxTales - tales.length).clamp(0, maxTales);
    final bool isFull = remaining == 0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFull
                    ? const Color(0xFFFFEDED)
                    : const Color(0xFFEEEDFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFull
                      ? Colors.redAccent.withAlpha(80)
                      : const Color(0xFF9947EB).withAlpha(60),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isFull ? '⚠️' : '✨',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFull
                              ? 'Masal limitine ulaştın!'
                              : 'Sihirli Masal Hakkın',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isFull
                                ? Colors.redAccent
                                : const Color(0xFF9947EB),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFull
                              ? 'Yeni masal oluşturmak için mevcut masallarını silebilirsin.'
                              : 'Kalan Hak: $remaining / $maxTales',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          value: remaining / maxTales,
                          strokeWidth: 4,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFull ? Colors.redAccent : const Color(0xFF9947EB),
                          ),
                        ),
                      ),
                      Text(
                        '$remaining',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isFull
                              ? Colors.redAccent
                              : const Color(0xFF9947EB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final tale = tales[i];
                return _TaleCard(
                  data: tale,
                  showDelete: true,
                  onDelete: () => onDelete(i),
                  isFavorite: favoriteIds.contains(tale['id']),
                  onFavoriteToggle: () => onFavoriteToggle(tale['id']),
                );
              },
              childCount: tales.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.72,
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HAZIR MASALLAR SEKMESİ
// ────────────────────────────────────────────────────────────────────────────

/// Alt gezinme çubuğunda "Hazır Masallar" seçildiğinde gösterilen sayfa (Index 1).
class _PredefinedTalesTab extends StatelessWidget {
  final Set<String> favoriteIds;
  final Function(String) onFavoriteToggle;

  const _PredefinedTalesTab({
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTales = ReadyTalesRegistry.getGroupedTales();

    if (groupedTales.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _EmptyTalesState(),
        ),
      );
    }

    // Ekrana ortalama 3 kart (hafifçe taşacak şekilde) sığdırmak için genişlik hesapla
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40 - (2 * 14)) / 2.8;

    return ListView.separated(
      padding: const EdgeInsets.only(top: 24, bottom: 100),
      itemCount: groupedTales.keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        final category = groupedTales.keys.elementAt(index);
        final categoryTales = groupedTales[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: cardWidth + 50, // Resim yüksekliği + metin alanı
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: categoryTales.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final tale = categoryTales[i];
                  return ReadyTaleCard(
                    tale: tale,
                    width: cardWidth,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// FAVORİLER SEKMESİ
// ────────────────────────────────────────────────────────────────────────────

/// Alt gezinme çubuğunda "Favoriler" seçildiğinde gösterilen sayfa (Index 3).
class _FavoritesTab extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteTales;
  final Function(String) onFavoriteToggle;

  const _FavoritesTab({
    required this.favoriteTales,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (favoriteTales.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.favorite_border_rounded,
                  size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text(
                'Henüz favori masalın yok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Masalları favorilerine eklemek için kalp ikonuna tıkla.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A94A6)),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.72,
      ),
      itemCount: favoriteTales.length,
      itemBuilder: (context, i) {
        final tale = favoriteTales[i];
        return _TaleCard(
          data: tale,
          showDelete:
              false, // You generally don't delete from db via favorites, just unfavorite
          isFavorite: true,
          onFavoriteToggle: () => onFavoriteToggle(tale['id']),
        );
      },
    );
  }
}
