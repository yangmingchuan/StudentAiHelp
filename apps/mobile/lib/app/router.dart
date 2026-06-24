import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/app/shell/app_shell.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/presentation/auth_splash_page.dart';
import 'package:little_hero/features/auth/presentation/login_page.dart';
import 'package:little_hero/features/auth/presentation/register_page.dart';
import 'package:little_hero/features/child_profile/presentation/profile_page.dart';
import 'package:little_hero/features/english_placeholder/presentation/english_placeholder_page.dart';
import 'package:little_hero/features/math_placeholder/presentation/math_placeholder_page.dart';
import 'package:little_hero/features/today_tasks/presentation/today_tasks_page.dart';
import 'package:little_hero/features/todos/presentation/todo_management_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
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
                path: '/math',
                builder: (context, state) => const MathPlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/english',
                builder: (context, state) => const EnglishPlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'todos',
                    builder: (context, state) => const TodoManagementPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
