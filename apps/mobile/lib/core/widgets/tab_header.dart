import 'package:flutter/material.dart';

/// Shared geometry prevents the mascot moving between the four root tabs.
class TabHeader extends StatelessWidget {
  const TabHeader({
    required this.child,
    this.isDay,
    this.showSurface = true,
    super.key,
  });

  final Widget child;
  final bool? isDay;
  final bool showSurface;
  static const mascotKey = ValueKey('tab-header-mascot');
  static const frameKey = ValueKey('tab-header-frame');
  static const mascotSize = 88.0;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final day = isDay ?? (hour >= 7 && hour < 17);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return SizedBox(
      key: frameKey,
      height: 120 * (scale < 1 ? 1 : scale),
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        color: showSurface ? const Color(0xF2FFFCF8) : Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 108, 8),
                child: Align(alignment: Alignment.centerLeft, child: child),
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: Image.asset(
                day
                    ? 'assets/mascots/day_explorer_cat.png'
                    : 'assets/mascots/night_astronaut_cat.png',
                key: mascotKey,
                width: mascotSize,
                height: mascotSize,
                fit: BoxFit.contain,
                semanticLabel: day ? '挥手的探险猫' : '挥手的宇航猫',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
