import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'profile_screen.dart';
import '../widgets/appbar/home_appbar.dart';
import '../widgets/appbar/home_bottom_nav.dart';
import '../core/constants/mock_data.dart';
import '../services/tale_service.dart';
import '../features/ready_tales/ready_tales_registry.dart';
import '../features/ready_tales/ready_tale_model.dart';
import '../features/ready_tales/widgets/ready_tale_card.dart';
import '../services/local_favorite_service.dart';
import '../main.dart';
import '../widgets/star_background.dart';

/// Ana Sayfa
class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int selectedIndex;
  late List<Map<String, dynamic>> allTales;
  final Set<String> favoriteIds = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    allTales = MockData.myTales;
    _loadMyTales();
  }

  // 5 sekme: Ana Sayfa, Hazır Masallar, Sihirli Masallar, Favoriler, Profilim
  List<Widget> get _screens => [
    _HomeDashboard(tales: allTales, favoriteIds: favoriteIds, isLoading: isLoading),
    _PredefinedTalesTab(
      favoriteIds: favoriteIds,
      onFavoriteToggle: toggleFavorite,
    ),
    _AllTalesTab(
      tales: allTales,
      onDelete: _deleteTale,
      favoriteIds: favoriteIds,
      onFavoriteToggle: toggleFavorite,
    ),
    _FavoritesTab(
      favoriteTales: _getFavoriteTales(),
      onFavoriteToggle: toggleFavorite,
    ),
    const ProfileScreen(),
  ];

  List<Map<String, dynamic>> _getFavoriteTales() {
    final List<Map<String, dynamic>> favorites = [];
    
    // Kullanıcı masallarından favorileri ekle
    for (var tale in allTales) {
      final id = tale['id'] as String? ?? tale['storyId'] as String?;
      if (id != null && favoriteIds.contains(id)) {
        favorites.add(tale);
      }
    }
    
    // Hazır masallardan favorileri ekle
    for (var readyTale in ReadyTalesRegistry.allTales) {
      final formattedId = readyTale.id.startsWith('ready_') ? readyTale.id : 'ready_${readyTale.id}';
      if (favoriteIds.contains(formattedId)) {
        favorites.add({
          'id': formattedId,
          'title': readyTale.title,
          'coverUrl': readyTale.coverAsset,
          'isReadyTale': true,
          'readyTale': readyTale,
        });
      }
    }
    
    return favorites;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() => selectedIndex = widget.initialIndex);
      _loadMyTales();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMyTales();
  }

  Future<void> _loadMyTales() async {
    try {
      final tales = await TaleService.getMyTales();
      final localFavs = await LocalFavoriteService.getFavorites();

      if (mounted) {
        final favIds = <String>{};
        for (final tale in tales) {
          final id = tale['id'] as String? ?? tale['storyId'] as String?;
          final meta = tale['metadata'] as Map<String, dynamic>?;
          if (id != null && meta != null && meta['isFavorite'] == true) {
            favIds.add(id);
          }
        }
        favIds.addAll(localFavs);

        setState(() {
          allTales = tales;
          MockData.myTales = tales;
          favoriteIds.clear();
          favoriteIds.addAll(favIds);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Masallar yüklenemedi: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void toggleFavorite(String id) async {
    final newFav = !favoriteIds.contains(id);
    setState(() {
      if (newFav) {
        favoriteIds.add(id);
      } else {
        favoriteIds.remove(id);
      }
    });
    
    try {
      if (id.startsWith('ready_')) {
        await LocalFavoriteService.toggleFavorite(id);
      } else {
        await TaleService.toggleFavorite(id, newFav);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (newFav) {
            favoriteIds.remove(id);
          } else {
            favoriteIds.add(id);
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
                final taleId = allTales[index]['id'];
                Navigator.of(context).pop();

                try {
                  await TaleService.deleteTale(taleId);
                  
                  if (mounted) {
                    setState(() {
                      allTales.removeAt(index);
                    });
                  }
                } catch (e) {
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

  void showLimitDialog() {
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
    final isDark = ref.watch(sleepModeProvider);

    return StarBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: selectedIndex == 4 ? null : HomeAppBar(currentIndex: selectedIndex),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() => selectedIndex = index);
        },
      ),
      floatingActionButton: selectedIndex == 0 || selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                if (allTales.length >= 10) {
                  showLimitDialog();
                } else {
                  context.push('/create');
                }
              },
              backgroundColor: const Color(0xFF9947EB),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
            )
          : null,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
    ));
  }
}

class _HomeDashboard extends ConsumerWidget {
  final List<Map<String, dynamic>> tales;
  final Set<String> favoriteIds;
  final bool isLoading;

  const _HomeDashboard({
    required this.tales,
    required this.favoriteIds,
    required this.isLoading,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9947EB)));
    }

    final state = context.findAncestorStateOfType<_HomeScreenState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MagicHeroCard(
            onAction: () {
              if (tales.length >= 10) {
                state?.showLimitDialog();
              } else {
                context.push('/create');
              }
            },
          ),
          const SizedBox(height: 16),
          if (tales.isNotEmpty) ...[
            _RecentTalesSection(
              recentTales: tales.take(4).toList(),
              favoriteIds: favoriteIds,
              onFavoriteToggle: (id) => state?.toggleFavorite(id),
              onSeeAll: () {
                state?.setState(() => state.selectedIndex = 2);
              },
            ),
          ] else ...[
            const SizedBox(height: 24),
            _EmptyTalesState(),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HERO KART
// ────────────────────────────────────────────────────────────────────────────

class _MagicHeroCard extends StatelessWidget {
  final VoidCallback onAction;

  const _MagicHeroCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 12 : 0, sigmaY: isDark ? 12 : 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? null : const Color(0xFFEEEDFC),
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.premiumGlassGradientStart, AppColors.premiumGlassGradientEnd],
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? Border.all(color: AppColors.pastelPurple.withAlpha(30), width: 1)
                : null,
            boxShadow: [
              if (isDark)
                const BoxShadow(
                  color: AppColors.premiumGlassGlow,
                  blurRadius: 24,
                  spreadRadius: -2,
                ),
              BoxShadow(
                color: isDark ? AppColors.premiumShadow : Colors.black.withAlpha(12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.pastelPurple.withAlpha(100) : const Color(0xFF9947EB),
                ),
                child: Icon(
                  Icons.auto_fix_high_rounded,
                  color: isDark ? AppColors.pastelPurple : Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sihirli Bir Macera Başlat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.offWhite : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hayalindeki karakterleri seç\nve kendi masalını hemen oluştur!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.lavenderGrey : const Color(0xFF8A94A6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
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
                    backgroundColor: isDark 
                        ? AppColors.pastelPurple.withAlpha(200)
                        : const Color(0xFF9947EB),
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
        ),
      ),
    );
  }
}

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sihirli Masallarım',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.offWhite 
                    : const Color(0xFF1A1A2E),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Tümünü Gör',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.pastelPurple 
                      : const Color(0xFF9947EB),
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

class _EmptyTalesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: Theme.of(context).brightness == Brightness.dark ? 8 : 0,
            sigmaY: Theme.of(context).brightness == Brightness.dark ? 8 : 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: isDark ? null : Colors.white,
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.premiumGlassGradientStart, AppColors.premiumGlassGradientEnd],
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.pastelPurple.withAlpha(30)
                  : const Color(0xFFEEEDFC),
              width: 1.5,
            ),
            boxShadow: [
              if (isDark)
                const BoxShadow(color: AppColors.premiumGlassGlow, blurRadius: 24, spreadRadius: -2),
              BoxShadow(
                color: isDark ? AppColors.premiumShadow : Colors.black.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('📖', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 10),
              Text(
                'Henüz masalın yok',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.offWhite 
                      : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'İlk masalını oluştur ve burada görün!',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A94A6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'İsimsiz Masal';
    String? coverUrl;

    if (data['isReadyTale'] == true) {
      title = data['title'];
      coverUrl = data['coverUrl'];
    } else if (data['content'] != null) {
      title = data['content']['title'] ?? title;
      final segments = data['content']['segments'];
      if (segments != null && segments is List && segments.isNotEmpty) {
        coverUrl = segments[0]['imageUrl'];
      }
    } else {
      title = data['title'] ?? title;
      coverUrl = data['coverUrl'];
      if (coverUrl == null && data['segments'] != null && data['segments'] is List && data['segments'].isNotEmpty) {
        coverUrl = data['segments'][0]['imageUrl'];
      }
    }

    String timeAgo = data['timeAgo'] as String? ?? '';
    if (timeAgo.isEmpty && data['isReadyTale'] != true) {
      final createdAt = data['savedAt'] ?? data['createdAt'];
      if (createdAt != null) {
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
    } else if (data['isReadyTale'] == true) {
      timeAgo = (data['readyTale'] as ReadyTale).category;
    }

    return GestureDetector(
      onTap: () {
        if (data['isReadyTale'] == true) {
          context.push('/ready_tale_detail', extra: data['readyTale']);
        } else {
          Map<String, dynamic> storyDataForScreen;
          if (data['content'] != null) {
            final storyId = data['id'] ?? data['storyId'];
            storyDataForScreen = {
              'title': data['content']['title'],
              'segments': data['content']['segments'],
              if (storyId != null) 'storyId': storyId,
              'isSavedTale': true,
            };
          } else {
            storyDataForScreen = {...data, 'isSavedTale': true};
          }
          context.push('/tale', extra: storyDataForScreen);
        }
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9947EB), Color(0xFF6B2DBF)],
                      ),
                    ),
                    child: (coverUrl != null && coverUrl.trim().isNotEmpty)
                        ? (coverUrl.startsWith('http')
                            ? Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.book,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              )
                            : Image.asset(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.book,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ))
                        : const Icon(
                            Icons.auto_stories,
                            color: Colors.white54,
                            size: 50,
                          ),
                  ),
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.offWhite 
                    : const Color(0xFF1A1A2E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 11, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.lavenderGrey 
                    : const Color(0xFF8A94A6)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HAZIR MASALLAR SEKMESİ
// ────────────────────────────────────────────────────────────────────────────

class _PredefinedTalesTab extends StatelessWidget {
  final Set<String> favoriteIds;
  final Function(String) onFavoriteToggle;

  const _PredefinedTalesTab({
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (ReadyTalesRegistry.allTales.isEmpty) {
      return const Center(child: Text('Hazır masal bulunamadı.'));
    }

    final groupedTales = ReadyTalesRegistry.getGroupedTales();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 40 - 16) / 2;
        
        return ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: groupedTales.keys.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = groupedTales.keys.elementAt(index);
            final talesInCategory = groupedTales[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.offWhite 
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: cardWidth + 50,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: talesInCategory.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final tale = talesInCategory[i];
                      final formattedId = tale.id.startsWith('ready_') ? tale.id : 'ready_${tale.id}';
                      
                      return ReadyTaleCard(
                        tale: tale,
                        width: cardWidth,
                        isFavorite: favoriteIds.contains(formattedId),
                        onFavoriteToggle: () => onFavoriteToggle(formattedId),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SİHİRLİ MASALLAR (Kullanıcı Masalları) SEKMESİ
// ────────────────────────────────────────────────────────────────────────────

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

    const int maxTales = 10;
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
                color: isFull ? const Color(0xFFFFEDED) : const Color(0xFFEEEDFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFull ? Colors.redAccent.withAlpha(80) : const Color(0xFF9947EB).withAlpha(60),
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
                          isFull ? 'Masal limitine ulaştın!' : 'Sihirli Masal Hakkın',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isFull ? Colors.redAccent : const Color(0xFF9947EB),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFull ? 'Yeni masal oluşturmak için mevcut masallarını silebilirsin.' : 'Kalan Hak: $remaining / $maxTales',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tale = tales[index];
                return _TaleCard(
                  data: tale,
                  showDelete: true,
                  onDelete: () => onDelete(index),
                  isFavorite: favoriteIds.contains(tale['id']),
                  onFavoriteToggle: () => onFavoriteToggle(tale['id']),
                );
              },
              childCount: tales.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// FAVORİLER SEKMESİ
// ────────────────────────────────────────────────────────────────────────────

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
              Text('❤️', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                'Henüz favori masalın yok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: favoriteTales.map((tale) {
                  return _TaleCard(
                    data: tale,
                    width: cardWidth,
                    isFavorite: true,
                    onFavoriteToggle: () => onFavoriteToggle(tale['id']),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
