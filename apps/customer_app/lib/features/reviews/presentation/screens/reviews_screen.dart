import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../restaurant/data/restaurant_repository.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    required this.restaurantId,
  });

  final String restaurantId;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Priya S.',
      'rating': 5.0,
      'date': '2 days ago',
      'text': 'The flavors were out of this world! Melt in mouth meat and perfect saffron fragrance. Arrived burning hot in 19 mins!',
      'dish': 'Dum Gosht Hyderabadi Biryani',
    },
    {
      'name': 'Vikram R.',
      'rating': 5.0,
      'date': '5 days ago',
      'text': 'Packaging is 10/10 with tamper-evident seal and eco-friendly terracotta bowls. ZestyGo lightning delivery never disappoints.',
      'dish': 'Zafrani Shahi Phirni',
    },
    {
      'name': 'Ananya K.',
      'rating': 4.5,
      'date': '1 week ago',
      'text': 'Great portion size and authentic Awadhi seasoning. Mirchi ka salan had the right kick without being overly oily.',
      'dish': 'Paneer Subz Dum Biryani',
    },
  ];

  void _showAddReviewModal(String restaurantName) {
    double selectedRating = 5.0;
    final textController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate $restaurantName',
                    style: const TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [1, 2, 3, 4, 5].map((star) {
                      return IconButton(
                        icon: Icon(
                          star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: ZestyColors.ratingGold,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() => selectedRating = star.toDouble());
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    style: const TextStyle(color: ZestyColors.textLight),
                    decoration: InputDecoration(
                      hintText: 'Share what you loved about the food and packaging...',
                      hintStyle: const TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1B171D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ZestyColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          setState(() {
                            _reviews.insert(0, {
                              'name': 'You (Aarav Sharma)',
                              'rating': selectedRating,
                              'date': 'Just now',
                              'text': textController.text.trim(),
                              'dish': 'Chef Recommendation',
                            });
                          });
                          Navigator.pop(modalCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thank you! Your verified review is published.')),
                          );
                        }
                      },
                      child: const Text('Post Verified Review'),
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

  @override
  Widget build(BuildContext context) {
    final restaurant = RestaurantRepository.getRestaurantById(widget.restaurantId);

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: Text('${restaurant.name} Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // 1. Rating Overview Hero Card
          ZestyGlassCard(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          restaurant.rating.toString(),
                          style: const TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded, color: ZestyColors.ratingGold, size: 28),
                      ],
                    ),
                    Text(
                      'Based on ${restaurant.reviewCount} reviews',
                      style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showAddReviewModal(restaurant.name),
                  icon: const Icon(Icons.rate_review_rounded, size: 16),
                  label: const Text('Rate Kitchen', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Verified Customer Reviews',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          ..._reviews.map((rev) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(ZestySpacing.md),
              decoration: BoxDecoration(
                color: ZestyColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ZestyColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ZestyColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          (rev['name'] as String).substring(0, 1),
                          style: const TextStyle(color: ZestyColors.primaryAmber, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rev['name'] as String,
                              style: const TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              rev['date'] as String,
                              style: const TextStyle(color: ZestyColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ZestyColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              rev['rating'].toString(),
                              style: const TextStyle(color: ZestyColors.secondary, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.star_rounded, color: ZestyColors.secondary, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rev['text'] as String,
                    style: const TextStyle(color: ZestyColors.textLight, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B171D),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ZestyColors.glassBorder),
                    ),
                    child: Text(
                      'Ordered: ${rev['dish']}',
                      style: const TextStyle(color: ZestyColors.primaryAmber, fontSize: 10, fontWeight: FontWeight.w600),
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
