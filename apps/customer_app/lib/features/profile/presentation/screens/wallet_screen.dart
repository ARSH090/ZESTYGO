import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _walletBalance = 450;

  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'ZESTYFEAST',
      'discount': 'FLAT ₹125 OFF',
      'desc': 'On gourmet orders above ₹499 across all verified kitchens',
      'tag': 'BEST VALUE',
    },
    {
      'code': 'GOURMET50',
      'discount': '50% OFF UP TO ₹150',
      'desc': 'Valid on your next 3 chef special and artisanal hand-made dishes',
      'tag': 'LIMITED TIME',
    },
    {
      'code': 'FREEDEL',
      'discount': 'FREE LIGHTNING DELIVERY',
      'desc': 'Enjoy zero delivery fees on orders above ₹249',
      'tag': 'POPULAR',
    },
    {
      'code': 'SWEETTREAT',
      'discount': 'FREE DESSERT / SHAKE',
      'desc': 'Add any dessert worth ₹149 for ₹0 on orders above ₹599',
      'tag': 'NEW',
    },
  ];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Cashback from Order #ord_8f2c',
      'date': 'Yesterday, 9:15 PM',
      'amount': '+₹45.00',
      'isCredit': true,
    },
    {
      'title': 'Paid for Truffle Burger Feast',
      'date': 'Oct 9, 2:10 PM',
      'amount': '-₹250.00',
      'isCredit': false,
    },
    {
      'title': 'Welcome Bonus Credited',
      'date': 'Oct 7, 11:30 AM',
      'amount': '+₹655.00',
      'isCredit': true,
    },
  ];

  void _showAddMoneyModal() {
    int selectedAmount = 500;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(ZestySpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Up ZestyGo Wallet',
                    style: TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Instant 1-tap checkout with no OTP delays',
                    style: TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [200, 500, 1000].map((amt) {
                      final isSelected = selectedAmount == amt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ChoiceChip(
                          label: Text('₹$amt'),
                          selected: isSelected,
                          selectedColor: ZestyColors.primary,
                          backgroundColor: ZestyColors.glassPill,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : ZestyColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedAmount = amt);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _walletBalance += selectedAmount;
                          _transactions.insert(0, {
                            'title': 'Wallet Top-up via Razorpay',
                            'date': 'Just now',
                            'amount': '+₹$selectedAmount.00',
                            'isCredit': true,
                          });
                        });
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('₹$selectedAmount added to ZestyGo Wallet!')),
                        );
                      },
                      child: Text('Add ₹$selectedAmount via UPI / Cards'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _copyCoupon(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code "$code" copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('Coupons & Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // 1. Wallet Balance Hero Card
          ZestyGlassCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1A14), Color(0xFF191319)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: ZestyColors.primaryAmber.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ZestyGo Balance',
                      style: TextStyle(
                        color: ZestyColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ZestyColors.primaryAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⚡ INSTANT REFUNDS READY',
                        style: TextStyle(
                          color: ZestyColors.primaryAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '₹$_walletBalance.00',
                  style: const TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _showAddMoneyModal,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Money', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/home'),
                      icon: const Icon(Icons.restaurant_menu_rounded, size: 16),
                      label: const Text('Spend on Food', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        side: const BorderSide(color: ZestyColors.glassBorder),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Active Coupons & Vouchers
          const Text(
            'Available Promo Coupons',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          ..._coupons.map((coupon) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ZestyColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ZestyColors.glassBorder),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(ZestySpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ZestyColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: ZestyColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    coupon['discount'] as String,
                                    style: const TextStyle(
                                      color: ZestyColors.textLight,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ZestyColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      coupon['tag'] as String,
                                      style: const TextStyle(
                                        color: ZestyColors.secondary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coupon['desc'] as String,
                                style: const TextStyle(
                                  color: ZestyColors.textMuted,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: ZestyColors.glassBorder, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ZestySpacing.md, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF120E14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ZestyColors.primaryAmber.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            coupon['code'] as String,
                            style: const TextStyle(
                              color: ZestyColors.primaryAmber,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _copyCoupon(coupon['code'] as String),
                          child: const Text('COPY CODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // 3. Wallet Activity
          const Text(
            'Recent Wallet Activity',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          ..._transactions.map((tx) {
            final isCredit = tx['isCredit'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZestyColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ZestyColors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isCredit ? ZestyColors.secondary : Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['title'] as String,
                          style: const TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tx['date'] as String,
                          style: const TextStyle(color: ZestyColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    tx['amount'] as String,
                    style: TextStyle(
                      color: isCredit ? ZestyColors.secondary : ZestyColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
