import 'package:common_models/common_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';

import '../../data/restaurant_repository.dart';

/// Restaurant menu and ordering screen with category navigation and live cart sync.
class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
    this.initialRestaurant,
  });

  final String restaurantId;
  final Restaurant? initialRestaurant;

  @override
  ConsumerState<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState
    extends ConsumerState<RestaurantDetailsScreen> {
  bool _vegOnly = false;
  String _selectedCategory = 'All';

  Restaurant _getRestaurant() {
    if (widget.initialRestaurant != null) return widget.initialRestaurant!;
    return RestaurantRepository.getRestaurantById(widget.restaurantId);
  }

  List<MenuItem> _getMenu() {
    return RestaurantRepository.getMenuForRestaurant(widget.restaurantId);
  }

  void _onAddItem(Restaurant restaurant, MenuItem item) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final result = cartNotifier.addItem(
      restaurant: restaurant,
      item: item,
    );

    if (result == AddToCartResult.restaurantConflict) {
      _showConflictDialog(restaurant, item);
    }
  }

  void _showConflictDialog(Restaurant newRestaurant, MenuItem item) {
    final currentCart = ref.read(cartProvider);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ZestyColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZestyRadius.card),
            side: const BorderSide(color: ZestyColors.glassBorder),
          ),
          title: const Text(
            'Replace cart items?',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Your cart contains dishes from "${currentCart.restaurantName}". '
            'Would you like to discard them and add items from "${newRestaurant.name}" instead?',
            style: const TextStyle(
              color: ZestyColors.textMuted,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ZestyColors.textMuted),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(cartProvider.notifier).replaceCartWithItem(
                      restaurant: newRestaurant,
                      item: item,
                    );
              },
              child: const Text('Replace Cart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _getRestaurant();
    final cart = ref.watch(cartProvider);
    final menuItems = _getMenu();

    final categories = [
      'All',
      ...{for (final item in menuItems) item.category},
    ];

    final filteredItems = menuItems.where((item) {
      if (_vegOnly && !item.isVeg) return false;
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Hero AppBar with Header Image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: ZestyColors.darkCanvas,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ZestyColors.darkCard,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, ZestyColors.darkCanvas],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Restaurant Metadata Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZestySpacing.md),
              child: ZestyGlassCard(
                padding: const EdgeInsets.all(ZestySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push('/restaurant/${restaurant.id}/reviews'),
                          borderRadius: BorderRadius.circular(ZestyRadius.chip),
                          child: ZestyRatingBadge(
                            rating: restaurant.rating,
                            reviewCount: restaurant.reviewCount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${restaurant.cuisinesDisplay} • ${restaurant.priceForTwo.format()} for two',
                      style: const TextStyle(
                        color: ZestyColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ZestyEtaChip(
                          etaText: restaurant.etaDisplay,
                          distanceText: restaurant.distanceDisplay,
                        ),
                        const SizedBox(width: 8),
                        if (restaurant.offers.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ZestyColors.primary.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(ZestyRadius.chip),
                              border: Border.all(
                                color:
                                    ZestyColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              restaurant.offers.first,
                              style: const TextStyle(
                                color: ZestyColors.primaryAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Veg-Only Filter Bar & Category Pills
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ZestySpacing.md,
                ZestySpacing.md,
                ZestySpacing.md,
                ZestySpacing.xs,
              ),
              child: Row(
                children: [
                  ZestyGlassPill(
                    isSelected: _vegOnly,
                    onTap: () {
                      setState(() {
                        _vegOnly = !_vegOnly;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ZestyVegBadge(size: 13),
                        const SizedBox(width: 6),
                        Text(
                          'Veg Only',
                          style: TextStyle(
                            color: _vegOnly
                                ? Colors.white
                                : ZestyColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ZestyGlassPill(
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ZestyColors.textLight,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Menu Items Section
          SliverPadding(
            padding: const EdgeInsets.all(ZestySpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredItems[index];
                  final qty = ref
                      .watch(cartProvider.notifier)
                      .getItemQuantity(item.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: ZestySpacing.md),
                    child: _MenuItemTile(
                      item: item,
                      quantity: qty,
                      onAdd: () => _onAddItem(restaurant, item),
                      onRemove: () =>
                          ref.read(cartProvider.notifier).removeItem(item.id),
                    ),
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ),

          // Bottom spacing for floating cart bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
      bottomSheet: cart.isNotEmpty ? _buildFloatingCartBar(cart) : null,
    );
  }

  Widget _buildFloatingCartBar(Cart cart) {
    return Container(
      color: ZestyColors.darkCanvas,
      padding: const EdgeInsets.fromLTRB(
        ZestySpacing.md,
        ZestySpacing.sm,
        ZestySpacing.md,
        ZestySpacing.lg,
      ),
      child: GestureDetector(
        onTap: () => context.push('/checkout'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: ZestyGradients.flame,
            borderRadius: BorderRadius.circular(ZestyRadius.card),
            boxShadow: [
              BoxShadow(
                color: ZestyColors.primary.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'ITEM' : 'ITEMS'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    cart.subtotal.format(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ZestyGlassCard(
      padding: const EdgeInsets.all(ZestySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isVeg)
                      const ZestyVegBadge(size: 14)
                    else
                      const ZestyNonVegBadge(size: 14),
                    if (item.isBestseller) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ZestyColors.primaryAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '★ Bestseller',
                          style: TextStyle(
                            color: ZestyColors.primaryAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price.format(),
                  style: const TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ZestyColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Quantity Stepper / ADD Button
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: ZestyColors.darkCard,
              borderRadius: BorderRadius.circular(ZestyRadius.xs),
              border: Border.all(color: ZestyColors.primary),
            ),
            child: quantity == 0
                ? TextButton(
                    onPressed: onAdd,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        color: ZestyColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: ZestyColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: onAdd,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: ZestyColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
