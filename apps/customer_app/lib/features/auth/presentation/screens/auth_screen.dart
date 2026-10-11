import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
        _otpController.text = '123456'; // Pre-filled test OTP for demo convenience
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent: 123456 (auto-filled for demo)')),
      );
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length < 6) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to ZestyGo, Aarav! 🎉')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(ZestySpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Cloche Logo
                const ZestyBrandLogo(size: 80, showText: true),
                const SizedBox(height: 12),
                const Text(
                  'GOURMET FOOD • LIGHTNING DELIVERY',
                  style: TextStyle(
                    color: ZestyColors.primaryAmber,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 36),

                // Card Container
                ZestyGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _otpSent ? 'Enter 6-Digit OTP' : 'Log In or Sign Up',
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _otpSent
                            ? 'Sent to +91 ${_phoneController.text}'
                            : 'Enter your phone number to proceed',
                        style: const TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      if (!_otpSent) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B171D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ZestyColors.glassBorder),
                              ),
                              child: const Text(
                                '🇮🇳 +91',
                                style: TextStyle(color: ZestyColors.textLight, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: ZestyColors.textLight, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: '10-digit number',
                                  hintStyle: const TextStyle(color: ZestyColors.textMuted),
                                  filled: true,
                                  fillColor: const Color(0xFF1B171D),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: ZestyColors.glassBorder),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Continue with Phone OTP'),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: ZestyColors.textLight, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: '••••••',
                            filled: true,
                            fillColor: const Color(0xFF1B171D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ZestyColors.glassBorder),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Verify & Enter'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _otpSent = false),
                            child: const Text('Change Phone Number', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Guest shortcut
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
