import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class ZestyGoApp extends ConsumerWidget {
  const ZestyGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ZestyGo',
      debugShowCheckedModeBanner: false,
      theme: buildZestyDarkTheme(),
      routerConfig: router,
    );
  }
}
