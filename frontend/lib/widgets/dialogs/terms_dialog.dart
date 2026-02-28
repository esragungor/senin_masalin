import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Google ile ilk kez giriş yapan kullanıcılara gösterilen
/// Kullanıcı Sözleşmesi onay dialog'u.
///
/// Döndürür: true → onayladı, false → reddetti / kapattı
Future<bool> showTermsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Dışarıya tıklayarak kapatılamaz
    builder: (ctx) => const _TermsDialog(),
  );
  return result ?? false;
}

class _TermsDialog extends StatefulWidget {
  const _TermsDialog();

  @override
  State<_TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<_TermsDialog> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: const Text(
        'Kullanıcı Sözleşmesi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.authInputText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google hesabınla devam etmeden önce kullanıcı sözleşmesini ve gizlilik politikasını okumanı istiyoruz.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 16),
          // Onay checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _accepted,
                  onChanged: (val) => setState(() => _accepted = val ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(
                    color: AppColors.authInputBorder,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _accepted = !_accepted),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'Kullanıcı Sözleşmesi ve Gizlilik Politikasını',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' okudum ve kabul ediyorum.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // İptal
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Vazgeç',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
        // Devam Et
        ElevatedButton(
          onPressed: _accepted ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.authPrimaryButton,
            foregroundColor: AppColors.authPrimaryButtonText,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Devam Et',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
