import 'package:little_hero/core/widgets/tab_header.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const cycleRose = Color(0xFFA94467);
const cycleInk = Color(0xFF433A42);

class _CycleDayScope extends InheritedWidget {
  const _CycleDayScope({required this.isDay, required super.child});
  final bool isDay;
  @override
  bool updateShouldNotify(_CycleDayScope oldWidget) => isDay != oldWidget.isDay;
}

/// Shares the home page's artwork, regular typography and rounded surfaces.
class CycleScene extends StatefulWidget {
  const CycleScene({
    required this.child,
    this.title,
    this.actions,
    this.onBack,
    super.key,
  });
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  @override
  State<CycleScene> createState() => _CycleSceneState();
}

class _CycleSceneState extends State<CycleScene> with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    final next = now.hour < 7
        ? DateTime(now.year, now.month, now.day, 7)
        : now.hour < 17
        ? DateTime(now.year, now.month, now.day, 17)
        : DateTime(now.year, now.month, now.day + 1, 7);
    _timer = Timer(next.difference(now) + const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _schedule();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDay = DateTime.now().hour >= 7 && DateTime.now().hour < 17;
    final base = Theme.of(context);
    final scheme = base.colorScheme.copyWith(
      primary: cycleRose,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFF9E3EB),
      onPrimaryContainer: cycleInk,
      secondary: cycleRose,
      secondaryContainer: const Color(0xFFF9E3EB),
      onSecondaryContainer: cycleInk,
      surface: const Color(0xFFFFFBF7),
      onSurface: cycleInk,
    );
    final content = Theme(
      data: base.copyWith(
        colorScheme: scheme,
        textTheme: base.textTheme.apply(
          bodyColor: cycleInk,
          displayColor: cycleInk,
        ),
        cardTheme: base.cardTheme.copyWith(color: const Color(0xF2FFFCF8)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: cycleInk,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: cycleInk,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDay ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                isDay
                    ? 'assets/backgrounds/day_meadow.png'
                    : 'assets/backgrounds/night_moon.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (widget.title != null)
                    Container(
                      color: const Color(0xEDFFFCF8),
                      child: Row(
                        children: [
                          BackButton(onPressed: widget.onBack),
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          ...?widget.actions,
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return _CycleDayScope(
      isDay: isDay,
      child: widget.title == null ? content : Scaffold(body: content),
    );
  }
}

class CycleCard extends StatelessWidget {
  const CycleCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}

class CycleHeading extends StatelessWidget {
  const CycleHeading({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final isDay =
        context.dependOnInheritedWidgetOfExactType<_CycleDayScope>()?.isDay ??
        true;
    return TabHeader(
      showSurface: false,
      isDay: isDay,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: isDay ? cycleInk : Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDay ? cycleInk : const Color(0xFFDDEBFF),
            ),
          ),
        ],
      ),
    );
  }
}

class CycleNumberField extends StatelessWidget {
  const CycleNumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 15)),
      const SizedBox(height: 4),
      Row(
        children: [
          Expanded(
            child: Text(
              '$value 天',
              style: const TextStyle(fontSize: 23, color: cycleRose),
            ),
          ),
          IconButton(
            tooltip: '$label减少',
            onPressed: value <= min ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          IconButton(
            tooltip: '$label增加',
            onPressed: value >= max ? null : () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    ],
  );
}

String cycleDateLabel(DateTime date) =>
    '${date.year}年${date.month}月${date.day}日';
EdgeInsets cyclePagePadding(BuildContext context) =>
    EdgeInsets.fromLTRB(16, 6, 16, MediaQuery.paddingOf(context).bottom + 24);
String cycleErrorText(Object error) =>
    error is ArgumentError ? error.message.toString() : '暂时无法保存，请稍后重试';
