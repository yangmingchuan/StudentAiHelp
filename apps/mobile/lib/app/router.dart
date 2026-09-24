import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/app/shell/app_shell.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/presentation/auth_splash_page.dart';
import 'package:little_hero/features/auth/presentation/login_page.dart';
import 'package:little_hero/features/auth/presentation/register_page.dart';
import 'package:little_hero/features/child_profile/presentation/profile_page.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_advice_page.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_analysis_page.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_diary_page.dart';
import 'package:little_hero/features/mama_tools/presentation/cycle_settings_page.dart';
import 'package:little_hero/features/mama_tools/presentation/mama_tools_page.dart';
import 'package:little_hero/features/medication/presentation/medication_home_page.dart';
import 'package:little_hero/features/today_tasks/presentation/today_tasks_page.dart';
import 'package:little_hero/features/todos/presentation/todo_management_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    refreshListenable: refresh,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoading = authState.isLoading;
      final isSignedIn = authState.asData?.value != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      if (!isSignedIn) {
        return isAuthRoute ? null : '/login';
      }
      if (isAuthRoute || state.matchedLocation == '/splash') {
        return '/tasks';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const AuthSplashPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/todos',
        builder: (context, state) => const TodoManagementPage(),
      ),
      GoRoute(
        path: '/profile/history',
        builder: (context, state) => const GrowthHistoryPage(),
      ),
      GoRoute(
        path: '/mama/settings',
        builder: (context, state) => const CycleSettingsPage(),
      ),
      GoRoute(
        path: '/mama/analysis',
        builder: (context, state) => const CycleAnalysisPage(),
      ),
      GoRoute(
        path: '/mama/advice',
        builder: (context, state) => const CycleAdvicePage(),
      ),
      GoRoute(
        path: '/mama/diary/:date',
        builder: (context, state) {
          final rawDate = state.pathParameters['date'] ?? '';
          return CycleDiaryPage(date: DateTime.parse(rawDate));
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TodayTasksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mama',
                builder: (context, state) => const MamaToolsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/medication',
                builder: (context, state) => const MedicationHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
