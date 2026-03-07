import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Yeni Masal Oluştur — Adım 1: Kahraman Bilgileri
/// Çocuğun adı, yaşı ve cinsiyeti alınır.
class CreateTaleScreen extends StatefulWidget {
  const CreateTaleScreen({super.key});

  @override
  State<CreateTaleScreen> createState() => _CreateTaleScreenState();
}

class _CreateTaleScreenState extends State<CreateTaleScreen> {
  final TextEditingController _nameController = TextEditingController();
  double _age = 5;
  String? _gender; // 'kız' | 'erkek'
  String? _selectedTheme;

  static const _purple = Color(0xFF9947EB);
  static const _lightPurple = Color(0xFFEEEDFC);
  static const _bgColor = Color(0xFFF7F6F8);

  final List<Map<String, dynamic>> _themes = [
    {
      'id': 'orman',
      'title': 'Orman',
      'emoji': '🌲',
      'bg': const Color(0xFFD1FAE5),
    },
    {
      'id': 'uzay',
      'title': 'Uzay',
      'emoji': '🚀',
      'bg': const Color(0xFFDBEAFE),
    },
    {
      'id': 'denizalti',
      'title': 'Denizaltı',
      'emoji': '🌊',
      'bg': const Color(0xFFCFFAFE),
    },
    {
      'id': 'sato',
      'title': 'Şato',
      'emoji': '🏰',
      'bg': const Color(0xFFE0E7FF),
    },
    {
      'id': 'dinozorlar',
      'title': 'Dinozorlar',
      'emoji': '🦖',
      'bg': const Color(0xFFECFCCB),
    },
    {
      'id': 'supergucler',
      'title': 'Süper Güçler',
      'emoji': '⚡',
      'bg': const Color(0xFFFEF08A),
    },
    {
      'id': 'sihirliokul',
      'title': 'Sihirli Okul',
      'emoji': '🏫',
      'bg': const Color(0xFFE9D5FF),
    },
    {
      'id': 'sekerdiyari',
      'title': 'Şeker Diyarı',
      'emoji': '🍭',
      'bg': const Color(0xFFFBCFE8),
    },
    {
      'id': 'korsanlar',
      'title': 'Korsanlar',
      'emoji': '🏴‍☠️',
      'bg': const Color(0xFFFFEDD5),
    },
    {
      'id': 'buzullar',
      'title': 'Buzullar',
      'emoji': '🧊',
      'bg': const Color(0xFFE0F2FE),
    },
    {
      'id': 'sirk',
      'title': 'Sirk',
      'emoji': '🎪',
      'bg': const Color(0xFFFECACA),
    },
    {
      'id': 'periler',
      'title': 'Periler Ülkesi',
      'emoji': '🧚‍♀️',
      'bg': const Color(0xFFFDE68A),
    },
    {
      'id': 'okyanus',
      'title': 'Okyanusun Dibi',
      'emoji': '🧜‍♀️',
      'bg': const Color(0xFFBAE6FD),
    },
    {
      'id': 'col',
      'title': 'Çölde Macera',
      'emoji': '🐪',
      'bg': const Color(0xFFFDE047),
    },
    {
      'id': 'hayvanlar',
      'title': 'Hayvanlar Alemi',
      'emoji': '🦁',
      'bg': const Color(0xFFD9F99D),
    },
    {
      'id': 'zaman',
      'title': 'Zaman Yolculuğu',
      'emoji': '⏳',
      'bg': const Color(0xFFDDD6FE),
    },
    {
      'id': 'bulutlar',
      'title': 'Bulutların Üstünde',
      'emoji': '☁️',
      'bg': const Color(0xFFE0F2FE),
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _gender != null && _selectedTheme != null;

  void _onDevam() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen adı girin ve cinsiyet seçin.'),
          backgroundColor: Color(0xFF9947EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    context.push('/create/step2', extra: {
      'childName': _nameController.text.trim(),
      'childAge': _age.round(),
      'gender': _gender,
      'theme': _selectedTheme,
    });
  }

  Color get _dynamicBg {
    if (_gender == 'kız') return const Color(0xFFFFF0F5);
    if (_gender == 'erkek') return const Color(0xFFEEF6FF);
    return _bgColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _dynamicBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Yeni Masal Oluştur',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ADIM 1 / 3',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _purple,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Color(0xFF1A1A2E), size: 22),
            onPressed: () => context.go('/home'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1 / 3,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(_purple),
            minHeight: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bölüm başlığı ─────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _purple.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person_rounded, color: _purple, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Kahraman kim?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Çocuğunuzun Adı ───────────────────────────────
            const Text(
              'Çocuğunuzun Adı',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Örn. Esra, Leo, Ali...',
                  hintStyle: const TextStyle(
                      color: Color(0xFFB0BAC9), fontSize: 15),
                  prefixIcon: const Icon(Icons.edit_rounded,
                      color: Color(0xFFB0BAC9), size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Yaş Slider ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yaş',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${_age.round()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _purple,
                        ),
                      ),
                      const TextSpan(
                        text: ' yaş',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _purple,
                inactiveTrackColor: _lightPurple,
                thumbColor: _purple,
                overlayColor: _purple.withAlpha(30),
                trackHeight: 6,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: _age,
                min: 2,
                max: 12,
                divisions: 10,
                onChanged: (v) => setState(() => _age = v),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFB0BAC9))),
                  Text('12',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFB0BAC9))),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Cinsiyet Seçimi ────────────────────────────
            const Text(
              'Cinsiyet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    label: 'Kız',
                    emoji: '👧',
                    isSelected: _gender == 'kız',
                    onTap: () => setState(() => _gender = 'kız'),
                    activeColor: const Color(0xFFFF6B9E),
                    activeBgColor: const Color(0xFFFFF0F5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _GenderCard(
                    label: 'Erkek',
                    emoji: '👦',
                    isSelected: _gender == 'erkek',
                    onTap: () => setState(() => _gender = 'erkek'),
                    activeColor: const Color(0xFF3B82F6), // Darker, clear blue
                    activeBgColor: const Color(0xFFDBEAFE), // Subtly darker soft background
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Temalar (Yatay Kaydırmalı) ────────────────
            const Text(
              'Nasıl bir masal olsun?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: _themes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final theme = _themes[i];
                  final isSelected = _selectedTheme == theme['id'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = theme['id']),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme['bg'],
                            border: Border.all(
                              color: isSelected ? _purple : Colors.white,
                              width: isSelected ? 3 : 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isSelected ? 12 : 6),
                                blurRadius: isSelected ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              theme['emoji'] as String,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? _purple : const Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 36),

            // ── Devam Et Butonu ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isValid ? _onDevam : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  disabledBackgroundColor: _lightPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Devam Et →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      ),     // closes Scaffold
    );       // closes AnimatedContainer
  }
}

/// Cinsiyet seçim kartı.
class _GenderCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color activeBgColor;

  const _GenderCard({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.activeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
