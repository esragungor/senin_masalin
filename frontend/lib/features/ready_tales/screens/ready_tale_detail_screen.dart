import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ready_tale_model.dart';

/// Hazır masala tıklandığında açılan "Kahraman kim olsun?" diyalogu.
class ReadyTaleDetailScreen extends StatefulWidget {
  final ReadyTale tale;

  const ReadyTaleDetailScreen({
    super.key,
    required this.tale,
  });

  @override
  State<ReadyTaleDetailScreen> createState() => _ReadyTaleDetailScreenState();

  /// Modal bottom sheet olarak gösterir
  static Future<void> show(BuildContext context, ReadyTale tale) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReadyTaleDetailScreen(tale: tale),
      ),
    );
  }
}

class _ReadyTaleDetailScreenState extends State<ReadyTaleDetailScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tale.defaultProtagonist);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startTale() {
    final name = _nameController.text.trim();
    
    // İsmi masalın içine yerleştir ({{PROTAGONIST}} replace edilir)
    final personalizedTale = widget.tale.applyProtagonist(name);
    
    // TaleScreen'in anladığı formata çevir
    final storyData = personalizedTale.toStoryData();

    // Dialogu kapat ve masala git
    Navigator.pop(context);
    context.push('/tale', extra: storyData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Kulp ──────────────────────────────────────────
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // ── İkon / Kapak ──────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9947EB), Color(0xFF6B2DBF)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9947EB).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.tale.coverAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      widget.tale.coverAsset!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),

          // ── Başlık ─────────────────────────────────────────
          Text(
            widget.tale.title.replaceAll('{{PROTAGONIST}}', widget.tale.defaultProtagonist),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Bu masalın kahramanı kim olsun?',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF8A94A6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // ── İsim Girişi ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                hintText: 'Çocuğunuzun adı',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Başla Butonu ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _startTale,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              label: const Text(
                'Masalı Başlat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9947EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
