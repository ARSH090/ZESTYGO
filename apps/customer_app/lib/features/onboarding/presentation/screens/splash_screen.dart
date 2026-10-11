import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen CUS-001: Animated Splash & Brand Launch
/// Faithful implementation of Stitch screen f401a53c2ded45bb9361bbe76e96e330
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowAnimation;

  int _statusIndex = 0;
  Timer? _statusTimer;
  Timer? _navigationTimer;

  static const List<String> _statusMessages = [
    'Igniting culinary flames...',
    'Curating top gourmet kitchens near you...',
    'Connecting lightning-fast delivery fleet...',
    'Ready to feast!',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat(reverse: true);

    // Rotate status messages
    _statusTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted && _statusIndex < _statusMessages.length - 1) {
        setState(() {
          _statusIndex++;
        });
      }
    });

    // Auto-proceed after 2.8 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ambient Background Saffron Radial Glow Orbs
          Positioned(
            top: size.height * 0.15,
            left: size.width * 0.5 - 190,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ZestyColors.primary.withValues(
                          alpha: _glowAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                      radius: 0.75,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ZestyColors.primaryAmber.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // 2. Center Content: Logo Emblem & Kinetic Animation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZestySpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Pulsing Brand Emblem
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: const ZestyBrandLogo(
                      size: 110,
                      showText: false,
                    ),
                  ),

                  const SizedBox(height: ZestySpacing.xl),

                  // Brand Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              color: ZestyColors.textLight,
                              fontFamily: 'sans-serif',
                            ),
                            children: [
                              TextSpan(text: 'Zesty'),
                              TextSpan(
                                text: 'Go',
                                style: TextStyle(
                                  color: ZestyColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: ZestySpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: ZestyColors.glassPill,
                            borderRadius: BorderRadius.circular(ZestyRadius.chip),
                            border: Border.all(color: ZestyColors.glassBorder),
                          ),
                          child: const Text(
                            'GOURMET FOOD • LIGHTNING DELIVERY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: ZestyColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 3. Frosted Launch Glass Card with Animated Progress
                  ZestyGlassCard(
                    padding: const EdgeInsets.all(ZestySpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Linear loading bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: ZestyColors.glassPill,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ZestyColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: ZestySpacing.md),

                        // Animated Microcopy
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _statusMessages[_statusIndex],
                            key: ValueKey<int>(_statusIndex),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ZestySpacing.md),

                  // Skip / Explore directly button
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Explore directly →',
                      style: TextStyle(
                        color: ZestyColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
