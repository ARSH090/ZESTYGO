import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/addresses/presentation/screens/addresses_screen.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/ecosystem/presentation/screens/ecosystem_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/orders/presentation/screens/order_details_screen.dart';
import '../features/profile/presentation/screens/payments_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/wallet_screen.dart';
import '../features/restaurant/presentation/screens/restaurant_screen.dart';
import '../features/reviews/presentation/screens/reviews_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/support/presentation/screens/support_screen.dart';
import '../features/tracking/presentation/screens/live_tracking_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/restaurant/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'res_001';
          return CustomTransitionPage(
            child: RestaurantDetailsScreen(restaurantId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/restaurant/:id/reviews',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'res_001';
          return CustomTransitionPage(
            child: ReviewsScreen(restaurantId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CheckoutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/tracking/:orderId',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? 'ord_demo123';
          return CustomTransitionPage(
            child: LiveTrackingScreen(orderId: orderId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/orders/:orderId',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? 'ord_demo123';
          return CustomTransitionPage(
            child: OrderDetailsScreen(orderId: orderId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/addresses',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AddressesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/payments',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PaymentsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WalletScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/support',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SupportScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/ecosystem',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const EcosystemScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      ),
      // Alias root '/' to /splash
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
    ],
  );
});
