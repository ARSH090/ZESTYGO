import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bootstrap route only. Replace with feature routes and role-aware redirect
/// guards from the authentication package as features are built.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('ZestyGo Delivery')),
        ),
      ),
    ],
  );
});
