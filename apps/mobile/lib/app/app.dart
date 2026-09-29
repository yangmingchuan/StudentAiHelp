import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/app/router.dart';
import 'package:little_hero/core/theme/app_theme.dart';
import 'package:little_hero/core/sync/sync_lifecycle.dart';

class LittleHeroApp extends ConsumerWidget {
  const LittleHeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return SyncLifecycle(
      child: MaterialApp.router(
        title: '猫咪打卡',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
