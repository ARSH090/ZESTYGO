import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _zestyPayAutoDebit = true;
  final List<String> _upiApps = [
    'Google Pay (aarav@okaxis)',
    'PhonePe (9876543210@ybl)',
    'Paytm UPI (9876543210@paytm)',
  ];

  final List<Map<String, String>> _cards = [
    {
      'type': 'HDFC Regalia Gold Visa',
      'last4': '4829',
      'expiry': '08/28',
      'color': '0xFF1E3A8A',
    },
    {
      'type': 'ICICI Coral RuPay Credit Card',
      'last4': '9102',
      'expiry': '11/27',
      'color': '0xFF831843',
    },
  ];

  void _showAddUpiModal() {
    final upiController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: ZestySpacing.lg,
            right: ZestySpacing.lg,
            top: ZestySpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + ZestySpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link New UPI ID / VPA',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: upiController,
                style: const TextStyle(color: ZestyColors.textLight),
                decoration: InputDecoration(
                  hintText: 'e.g. mobile@upi or username@okhdfcbank',
                  hintStyle: const TextStyle(color: ZestyColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFF1B171D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ZestyColors.glassBorder),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final text = upiController.text.trim();
                    if (text.contains('@')) {
                      setState(() {
                        _upiApps.add(text);
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UPI ID verified and linked!')),
                      );
                    }
                  },
                  child: const Text('Verify & Link UPI ID'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCardModal() {
    final numberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: ZestySpacing.lg,
            right: ZestySpacing.lg,
            top: ZestySpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + ZestySpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Credit or Debit Card',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: numberCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: ZestyColors.textLight),
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: const TextStyle(color: ZestyColors.textMuted),
                  hintText: 'xxxx xxxx xxxx xxxx',
                  filled: true,
                  fillColor: const Color(0xFF1B171D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ZestyColors.glassBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryCtrl,
                      keyboardType: TextInputType.datetime,
                      style: const TextStyle(color: ZestyColors.textLight),
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        labelStyle: const TextStyle(color: ZestyColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFF1B171D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ZestyColors.glassBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: ZestyColors.textLight),
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        labelStyle: const TextStyle(color: ZestyColors.textMuted),
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
                  onPressed: () {
                    if (numberCtrl.text.length >= 4) {
                      final l4 = numberCtrl.text.replaceAll(' ', '');
                      setState(() {
                        _cards.add({
                          'type': 'Custom Bank Card',
                          'last4': l4.substring(l4.length - 4),
                          'expiry': expiryCtrl.text.isEmpty ? '12/28' : expiryCtrl.text,
                          'color': '0xFF374151',
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card securely saved with RBI tokenization!')),
                      );
                    }
                  },
                  child: const Text('Save Card Securely'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('Payment Modes & UPI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // 1. Zesty Wallet Fast Checkout
          ZestyGlassCard(
            borderColor: ZestyColors.primary.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ZestyColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: ZestyColors.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZestyPay Balance',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '₹450.00 Available • 1-Tap Checkout',
                        style: TextStyle(color: ZestyColors.secondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _zestyPayAutoDebit,
                  activeThumbColor: ZestyColors.primary,
                  onChanged: (val) => setState(() => _zestyPayAutoDebit = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. UPI Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'UPI Accounts',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: _showAddUpiModal,
                child: const Text('+ Add UPI ID', style: TextStyle(color: ZestyColors.primaryAmber)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._upiApps.map(
            (upi) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: ZestyColors.darkCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: ZestyColors.glassBorder),
                ),
                child: ListTile(
                  leading: const Icon(Icons.flash_on_rounded, color: ZestyColors.primaryAmber),
                  title: Text(
                    upi,
                    style: const TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Text(
                    'LINKED',
                    style: TextStyle(color: ZestyColors.secondary, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Saved Cards Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Cards (RBI Compliant)',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: _showAddCardModal,
                child: const Text('+ Add Card', style: TextStyle(color: ZestyColors.primaryAmber)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._cards.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(ZestySpacing.md),
              decoration: BoxDecoration(
                color: Color(int.parse(c['color']!)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c['type']!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const Icon(Icons.credit_card_rounded, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '•••• •••• •••• ${c['last4']}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expires: ${c['expiry']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const Text(
                        'SECURED',
                        style: TextStyle(color: ZestyColors.secondary, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Pay On Delivery
          Material(
            color: ZestyColors.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ZestyColors.glassBorder),
            ),
            child: const ListTile(
              leading: Icon(Icons.local_shipping_outlined, color: ZestyColors.primaryAmber),
              title: Text(
                'Cash on Delivery / UPI on Delivery',
                style: TextStyle(color: ZestyColors.textLight, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Pay cash or scan QR when rider arrives',
                style: TextStyle(color: ZestyColors.textMuted, fontSize: 12),
              ),
              trailing: Icon(Icons.check_circle_rounded, color: ZestyColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
