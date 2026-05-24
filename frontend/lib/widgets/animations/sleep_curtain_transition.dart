import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SleepCurtainTransition {
  static void trigger(BuildContext context, {required VoidCallback onThemeToggle}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CurtainOverlayParams(
        onComplete: () {
          overlayEntry.remove();
        },
        onThemeToggle: onThemeToggle,
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _CurtainOverlayParams extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onComplete;

  const _CurtainOverlayParams({
    required this.onThemeToggle,
    required this.onComplete,
  });

  @override
  State<_CurtainOverlayParams> createState() => _CurtainOverlayParamsState();
}

class _CurtainOverlayParamsState extends State<_CurtainOverlayParams>
    with TickerProviderStateMixin {
  late AnimationController _curtainController;
  late Animation<double> _curtainAnimation;

  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _curtainController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _curtainAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _curtainController,
        curve: Curves.easeInOut,
      ),
    );

    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _playSequence();
  }

  Future<void> _playSequence() async {
    // 1. Curtain drops (600ms)
    await _curtainController.forward();

    // Theme switches instantly behind the curtain
    widget.onThemeToggle();

    // 2. Wait 400ms, then Text fades in
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) await _textController.forward();

    // 3. Keep text visible for 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));

    // 4. Text fades out while curtain rolls UP
    if (mounted) _textController.reverse();

    // 5. Curtain rolls back UP (by reversing the tween effect, or sliding to top)
    // To slide back up via the top, we just reverse the controller. It will go from 0 to -1.
    if (mounted) await _curtainController.reverse();

    // Done
    widget.onComplete();
  }

  @override
  void dispose() {
    _curtainController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _curtainController,
      builder: (context, child) {
        // If begin is -1.0 and end is 0.0,
        // height of container is always max, but top changes from -screenHeight to 0.
        return Positioned(
          left: 0,
          right: 0,
          top: _curtainAnimation.value * screenHeight,
          height: screenHeight,
          child: Material(
            color: const Color(0xFF0D0B1E),
            child: Center(
              child: FadeTransition(
                opacity: _textController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "İyi Geceler",
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8D5FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Masallar seni rüyanda bekliyor...",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF7B6FA0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
