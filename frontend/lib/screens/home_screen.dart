import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ana Sayfa — şu an boş placeholder.
/// İleride masal listesi, jeton bilgisi vb. eklenecek.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.authAppBarBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Senin Masalın',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.authAppBarTitle,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.authAppBarTitle),
            onPressed: () async {
              // TODO: AuthService.signOut() + navigate to login
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏠', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'Ana Sayfa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.authInputText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yakında masal dolu olacak!',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
