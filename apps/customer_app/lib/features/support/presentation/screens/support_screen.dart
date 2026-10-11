import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final String timestamp;
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Namaste Aarav! 🙏 Welcome to ZestyGo 24x7 Gourmet Support. How can we delight you today?',
      isUser: false,
      timestamp: 'Just now',
    ),
  ];

  final List<String> _quickPrompts = [
    'Where is my order #ord_8f2c?',
    'I want to cancel my order',
    'Payment debited twice',
    'Report missing or spilled item',
    'Connect to human agent',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text.trim(),
          isUser: true,
          timestamp: 'Just now',
        ),
      );
    });
    _chatController.clear();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      String response = 'Our support executive is checking your order details...';
      final lower = text.toLowerCase();
      if (lower.contains('where') || lower.contains('order')) {
        response =
            'Your active order #ord_8f2c from The Royal Biryani Darbar is currently PREPARING. Delivery partner Rajesh Kumar is at the restaurant. ETA is ~20 mins! 🛵';
      } else if (lower.contains('cancel')) {
        response =
            'Since the restaurant has started cooking your fresh feast, cancellations incur a kitchen prep fee. Would you like us to pause your delivery instead?';
      } else if (lower.contains('payment') || lower.contains('debited')) {
        response =
            'Any duplicate Razorpay deduction is auto-refunded to source within 24-48 hours. Reference UTR: RZP_IDEMP_71940.';
      } else if (lower.contains('missing') || lower.contains('spill')) {
        response =
            'We are deeply sorry! 💔 Please share a photo and our instant resolution system will credit a ₹150 apology voucher to your ZestyGo Wallet.';
      } else if (lower.contains('human') || lower.contains('agent')) {
        response =
            'Connecting you to Priya M. from Gourmet Escalations. Ringing support line now... 📞';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: 'Just now',
          ),
        );
      });

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('24x7 Customer Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded, color: ZestyColors.secondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling ZestyGo Priority Hotline: 1800-ZESTY-GO')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Help Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1D171C),
            child: Row(
              children: [
                const Icon(Icons.electric_bolt_rounded, color: ZestyColors.primaryAmber, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Active Order: #ord_8f2c (Biryani Darbar) • In Prep',
                    style: TextStyle(color: ZestyColors.textLight, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/tracking/ord_live_8f2c'),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
                  child: const Text('Track ➔', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(ZestySpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isUser ? ZestyColors.primary : ZestyColors.darkCard,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(2) : const Radius.circular(16),
                        bottomLeft: !msg.isUser ? const Radius.circular(2) : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color: msg.isUser ? Colors.transparent : ZestyColors.glassBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.timestamp,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quickPrompts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(p),
                    backgroundColor: ZestyColors.glassPill,
                    labelStyle: const TextStyle(color: ZestyColors.textLight, fontSize: 11),
                    onPressed: () => _sendMessage(p),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            color: ZestyColors.darkCard,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: ZestyColors.textLight, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type your message or issue...',
                      hintStyle: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF161217),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: ZestyColors.glassBorder),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  onPressed: () => _sendMessage(_chatController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
