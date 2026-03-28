import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // sleepModeProvider
import '../services/tale_service.dart';
import '../services/local_favorite_service.dart';
import '../services/achievement_service.dart';
import '../services/puzzle_service.dart';
import '../services/image_export_service.dart';
import '../widgets/appbar/home_bottom_nav.dart';

/// Profil Sayfası
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _taleCount = 0;
  int _favoriteCount = 0;
  int _tokens = 0;
  List<String> _claimedAchievements = [];
  Map<String, int> _achievementProgresses = {};
  bool _isLoadingStats = true;
  int _puzzleCount = 0;
  List<int> _revealedIndices = [];
  String _puzzleImage = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final tales = await TaleService.getMyTales();
      final localFavs = await LocalFavoriteService.getFavorites();

      // Backend favori sayısı
      int backendFavs = 0;
      for (final tale in tales) {
        final meta = tale['metadata'] as Map<String, dynamic>?;
        if (meta != null && meta['isFavorite'] == true) {
          backendFavs++;
        }
      }

      final readCount = await AchievementService.getReadCount();
      final tokens = await AchievementService.getTokens();
      final claimedList = await AchievementService.getClaimedAchievements();

      final Map<String, int> progresses = {};
      for (var ach in AchievementService.achievements) {
        progresses[ach.id] = await AchievementService.getAchievementProgress(ach.id);
      }

      final revealedIndices = await PuzzleService.getRevealedIndices();
      final puzzleCount = revealedIndices.length;
      final puzzleImage = await PuzzleService.getCurrentPuzzleImage();

      if (mounted) {
        setState(() {
          _taleCount = readCount;
          _tokens = tokens;
          _claimedAchievements = claimedList;
          _achievementProgresses = progresses;
          _favoriteCount = backendFavs + localFavs.length;
          _puzzleCount = puzzleCount;
          _revealedIndices = revealedIndices;
          _puzzleImage = puzzleImage;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          'Hesabından çıkmak istediğine emin misin?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF8A94A6), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = ref.watch(sleepModeProvider);

    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : '?');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // ── Başlık Kısmı (AppBar yerine) ──────────────
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profilim ve Başarımlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
            _ProfileHeader(
              displayName: displayName,
              photoUrl: photoUrl,
              initial: initial,
              taleCount: _taleCount,
              tokens: _tokens,
              claimedAchievements: _claimedAchievements,
            ),
            const SizedBox(height: 24),
            
            // ── Günün Puzzle'ı ────────────────────────────
            _DailyPuzzleCard(
              collectedCount: _puzzleCount, 
              revealedIndices: _revealedIndices,
              totalCount: 9, 
              imagePath: _puzzleImage,
              onRefresh: _loadStats,
            ),
            
            const SizedBox(height: 24),

            // ── Başarımlar Listesi ────────────────────────
            _AchievementsList(
              progresses: _achievementProgresses,
              claimedIds: _claimedAchievements,
              onClaim: (achId) async {
                await AchievementService.claimAchievement(achId);
                _loadStats(); // Yenilemek için
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// BÖLÜM 2: Günün Puzzle'ı
// ────────────────────────────────────────────────────────────────────────────

class _DailyPuzzleCard extends StatelessWidget {
  final int collectedCount;
  final List<int> revealedIndices;
  final int totalCount;
  final String imagePath;
  final VoidCallback onRefresh;

  const _DailyPuzzleCard({
    required this.collectedCount,
    required this.revealedIndices,
    required this.totalCount,
    required this.imagePath,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Toplam parça sayısını 9 olarak sabitliyoruz (3x3 grid)
    const int effectiveTotal = 9;
    bool isComplete = collectedCount >= effectiveTotal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      "Günün Puzzle'ı",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                    // TEST İÇİN: Gizli parça ekleme butonu
                    IconButton(
                      onPressed: () async {
                        await PuzzleService.addPiece(bypassDailyLimit: true);
                        onRefresh();
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                TextButton.icon(
                  onPressed: () async {
                    await ImageExportService.saveImage(imageUrl: imagePath);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Puzzle galerinize kaydedildi!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18, color: Color(0xFF9947EB)),
                  label: const Text('İndir', style: TextStyle(color: Color(0xFF9947EB), fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // ── Puzzle Reveal Grid ───────────────────────────
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                // Arka plandaki tam resim
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                
                // Üzerindeki kapatıcı parçalar (7 parça için 3x3 grid kullanıyoruz, son 2'si boş veya birleşik olabilir)
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: effectiveTotal, 
                  itemBuilder: (context, index) {
                    bool revealed = revealedIndices.contains(index);
                    
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: revealed ? 0.0 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
                        ),
                        child: Center(
                          child: Icon(Icons.extension_rounded, color: Colors.indigo.withOpacity(0.2), size: 24),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          // ── Durum Metni & Reset ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isComplete ? 'Tebrikler! Puzzle Tamamlandı 🎉' : '$collectedCount/$effectiveTotal parça toplandı.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isComplete ? const Color(0xFF9947EB) : const Color(0xFF8A94A6),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isComplete)
                TextButton(
                  onPressed: () async {
                    await PuzzleService.resetPuzzle();
                    onRefresh();
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Yenile', style: TextStyle(color: Color(0xFF8A94A6), fontSize: 13)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String? photoUrl;
  final String initial;
  final int taleCount;
  final int tokens;
  final List<String> claimedAchievements;

  const _ProfileHeader({
    required this.displayName,
    required this.photoUrl,
    required this.initial,
    required this.taleCount,
    required this.tokens,
    required this.claimedAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // ── Büyük yuvarlak avatar ─────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitial(initial),
                    )
                  : _buildInitial(initial),
            ),
          ),

          const SizedBox(height: 18),

          // ── İsim (veya Başarım İsmi) ──────────────────────
          Text(
            () {
              if (claimedAchievements.isEmpty) return displayName.isNotEmpty ? displayName : 'Kaşif';
              // Aktif olan en son başarımı bul
              final lastAchId = claimedAchievements.last;
              final ach = AchievementService.achievements.firstWhere(
                (a) => a.id == lastAchId, 
                orElse: () => AchievementService.achievements.first
              );
              return ach.title; // Örneğin: Gümüş Kitap Kurdu
            }(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // ── Masal sayısı ──────────────────────────────────
          Text(
            'Okunan Masal Sayısı: $taleCount',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 4),

          // ── Jeton Sayısı ──────────────────────────────────
          if (tokens > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/coin.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '$tokens Jeton Olarak Mükemmelsin',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFBBF24),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFC107), size: 20),
                const SizedBox(width: 6),
                const Text(
                  '0 Başarım Jetonu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Container(
      color: const Color(0xFFEEEDFC),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9947EB),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// BÖLÜM 2: İstatistikler
// ────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int taleCount;
  final int favoriteCount;
  final bool isLoading;

  const _StatsRow({
    required this.taleCount,
    required this.favoriteCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.auto_fix_high_rounded,
            iconColor: const Color(0xFF9947EB),
            bgColor: const Color(0xFFEEEDFC),
            value: isLoading ? '—' : '$taleCount',
            label: 'Sihirli Masal',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_rounded,
            iconColor: Colors.redAccent,
            bgColor: const Color(0xFFFFEDED),
            value: isLoading ? '—' : '$favoriteCount',
            label: 'Favori',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_stories_rounded,
            iconColor: const Color(0xFF4CAF50),
            bgColor: const Color(0xFFE8F5E9),
            value: isLoading ? '—' : '$taleCount',
            label: 'Okunan Masal',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// BÖLÜM 3: Ayarlar
// ────────────────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_rounded,
            iconColor: const Color(0xFF4CAF50),
            bgColor: const Color(0xFFE8F5E9),
            title: 'Bildirimler',
            subtitle: 'Masal hatırlatmaları',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFB0BAC9),
            ),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF2196F3),
            bgColor: const Color(0xFFE3F2FD),
            title: 'Yardım & Destek',
            subtitle: 'SSS ve iletişim',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFB0BAC9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 60, endIndent: 0, color: Color(0xFFF0F0F0));
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// BÖLÜM 4: Çıkış Butonu
// ────────────────────────────────────────────────────────────────────────────

class _DangerSection extends StatelessWidget {
  final VoidCallback onSignOut;

  const _DangerSection({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onSignOut,
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        label: const Text(
          'Çıkış Yap',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// BÖLÜM 5: Başarımlar Listesi
// ────────────────────────────────────────────────────────────────────────────

class _AchievementsList extends StatelessWidget {
  final Map<String, int> progresses;
  final List<String> claimedIds;
  final Function(String) onClaim;

  const _AchievementsList({
    required this.progresses,
    required this.claimedIds,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Başarımların",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        // Burada Claim edilmemiş (Toplanmamış) başarımları listeliyoruz
        ...AchievementService.achievements.where((ach) => !claimedIds.contains(ach.id)).map((ach) {
          final isClaimed = claimedIds.contains(ach.id);
          final progress = progresses[ach.id] ?? 0;
          final isClaimable = progress >= ach.target && !isClaimed;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AchievementCard(
              achievement: ach,
              progress: progress,
              isClaimed: isClaimed,
              isClaimable: isClaimable,
              onClaim: () => onClaim(ach.id),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int progress;
  final bool isClaimed;
  final bool isClaimable;
  final VoidCallback onClaim;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
    required this.isClaimed,
    required this.isClaimable,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (progress / achievement.target).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // İkon Bölümü
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F0FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.emoji_events_rounded, color: Color(0xFF9947EB), size: 28),
            ),
          ),
          const SizedBox(width: 16),
          // İçerik Bölümü
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isClaimable) ...[
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Jetonunu Al 🪙', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  )
                ] else if (isClaimed) ...[
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Toplandı',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                ] else ...[
                  // Claim edilmemiş ve henüz hedefe ulaşmamış (progress)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$progress/${achievement.target}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A94A6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
