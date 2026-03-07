import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Yeni Masal Oluştur — Adım 2: Tema ve Detaylar
/// Tema seçimi, yan karakter, özel nesne ve öğüt alınır.
class CreateTaleStep2Screen extends StatefulWidget {
  final String childName;
  final int childAge;
  final String gender;
  final String theme;

  const CreateTaleStep2Screen({
    super.key,
    required this.childName,
    required this.childAge,
    required this.gender,
    required this.theme,
  });

  @override
  State<CreateTaleStep2Screen> createState() => _CreateTaleStep2ScreenState();
}

class _CreateTaleStep2ScreenState extends State<CreateTaleStep2Screen> {
  final TextEditingController _companionController = TextEditingController();
  final TextEditingController _objectController = TextEditingController();
  final TextEditingController _moralController = TextEditingController();

  static const _purple = Color(0xFF9947EB);
  static const _bgColor = Color(0xFFF7F6F8);

  final List<Map<String, dynamic>> _predefinedMorals = [
    {'title': 'Dürüst olmak', 'emoji': '😇', 'color': const Color(0xFFE9D5FF), 'border': const Color(0xFFC084FC)},
    {'title': 'Paylaşmak', 'emoji': '💖', 'color': const Color(0xFFFBCFE8), 'border': const Color(0xFFF472B6)},
    {'title': 'Cesaret', 'emoji': '🦁', 'color': const Color(0xFFFEF08A), 'border': const Color(0xFFFACC15)},
    {'title': 'Arkadaşlık', 'emoji': '🤝', 'color': const Color(0xFFBFDBFE), 'border': const Color(0xFF60A5FA)},
    {'title': 'Yardımlaşma', 'emoji': '🦸‍♂️', 'color': const Color(0xFFA7F3D0), 'border': const Color(0xFF34D399)},
    {'title': 'Doğayı sevmek', 'emoji': '🌱', 'color': const Color(0xFFD1FAE5), 'border': const Color(0xFF10B981)},
    {'title': 'Sabırlı olmak', 'emoji': '⏳', 'color': const Color(0xFFFFEDD5), 'border': const Color(0xFFFB923C)},
    {'title': 'Özgüven', 'emoji': '🌟', 'color': const Color(0xFFE0E7FF), 'border': const Color(0xFF818CF8)},
  ];

  @override
  void initState() {
    super.initState();
    _companionController.addListener(_onTextChanged);
    _objectController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _isValid =>
      _companionController.text.trim().isNotEmpty &&
      _objectController.text.trim().isNotEmpty;

  Color get _dynamicBg {
    if (widget.gender == 'kız') return const Color(0xFFFFF0F5);
    if (widget.gender == 'erkek') return const Color(0xFFDBEAFE); // Updated darker, soft blue
    return _bgColor;
  }

  @override
  void dispose() {
    _companionController.removeListener(_onTextChanged);
    _objectController.removeListener(_onTextChanged);
    _companionController.dispose();
    _objectController.dispose();
    _moralController.dispose();
    super.dispose();
  }

  void _onMasalOlustur() {
    context.push('/generating', extra: {
      'childName': widget.childName,
      'childAge': widget.childAge,
      'gender': widget.gender,
      'theme': widget.theme,
      'companion': _companionController.text.trim(),
      'specialObject': _objectController.text.trim(),
      'moral': _moralController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dynamicBg,
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
              'ADIM 2 / 3',
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
            value: 2 / 3,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(_purple),
            minHeight: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── İsteğe Bağlı Detaylar ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  _buildTextField(
                    label: 'Yanında kim olsun?',
                    hint: 'Örn: En yakın arkadaşı, bir köpek...',
                    icon: Icons.group_rounded,
                    controller: _companionController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Özel bir nesne veya kahraman?',
                    hint: 'Örn: Uçan halı, sihirli kılıç...',
                    icon: Icons.auto_awesome_rounded,
                    controller: _objectController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Bir öğüt verelim mi? (İsteğe Bağlı)',
                    hint: 'Örn: Yalan söylememek, paylaşmak...',
                    icon: Icons.lightbulb_rounded,
                    controller: _moralController,
                  ),
                  const SizedBox(height: 16),

                  // ── Hazır Öğütler (Chips) ─────────────────
                  const Text(
                    'Veya hızlıca seç:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: _predefinedMorals.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final moralData = _predefinedMorals[i];
                        final title = moralData['title'] as String;
                        final emoji = moralData['emoji'] as String;
                        final bgColor = moralData['color'] as Color;
                        final borderColor = moralData['border'] as Color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _moralController.text = title;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: bgColor.withAlpha(150),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: borderColor.withAlpha(100),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: borderColor.withBlue(borderColor.blue ~/ 2).withRed(borderColor.red ~/ 2).withGreen(borderColor.green ~/ 2).withAlpha(255),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Masalı Oluştur Butonu ────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isValid ? _onMasalOlustur : null,
                      icon: const Text('✨', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        'Masalı Oluştur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        disabledBackgroundColor: const Color(0xFFEEEDFC),
                        disabledForegroundColor: const Color(0xFFB0BAC9),

                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
                  color: Colors.black.withAlpha(6),
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0BAC9), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFB0BAC9), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
