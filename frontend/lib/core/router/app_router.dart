import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/create_tale_screen.dart';
import '../../screens/create_tale_step2_screen.dart';
import '../../screens/tale_generating_screen.dart';
import '../../screens/tale_screen.dart';
import '../../screens/tale_completed_screen.dart';
import '../../screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialIndex = extra?['index'] as int? ?? 0;
          return HomeScreen(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateTaleScreen(),
        routes: [
          GoRoute(
            path: 'step2',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return CreateTaleStep2Screen(
                childName: extra['childName'] as String? ?? '',
                childAge: extra['childAge'] as int? ?? 5,
                gender: extra['gender'] as String? ?? 'kız',
                theme: extra['theme'] as String? ?? 'orman',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/generating',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TaleGeneratingScreen(
            childName: extra['childName'] as String?,
            childAge: extra['childAge'] as int?,
            gender: extra['gender'] as String? ?? 'kız',
            theme: extra['theme'] as String?,
            companion: extra['companion'] as String?,
            specialObject: extra['specialObject'] as String?,
            moral: extra['moral'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/tale',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TaleScreen(storyData: extra);
        },
        routes: [
          GoRoute(
            path: 'completed',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TaleCompletedScreen(storyData: extra);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
