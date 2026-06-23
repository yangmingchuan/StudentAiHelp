import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_hero/app/app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LittleHeroApp()));
}
