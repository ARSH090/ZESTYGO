import 'package:common_models/common_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen CUS-002: Customer Home & Food Discovery + Core Tabs
/// Faithful implementation of Stitch screen 6b30bcf286384812a6bb6e62b643cd4e
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  String _selectedCuisineId = 'all';
  bool _pureVegOnly = false;
  bool _fastDeliveryOnly = false;
  bool _topRatedOnly = false;
  String _selectedAddress = '12th Main, Indiranagar, Bengaluru';
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _favoriteRestaurantIds = {'res_001', 'res_003'};

  static const List<CuisineCategory> _cuisines = [
    CuisineCategory(id: 'all', name: 'All Dishes', iconEmoji: '✨'),
    CuisineCategory(id: 'biryani', name: 'Biryani', iconEmoji: '🍲'),
    CuisineCategory(id: 'burger', name: 'Burgers', iconEmoji: '🍔'),
    CuisineCategory(id: 'pizza', name: 'Pizza', iconEmoji: '🍕'),
    CuisineCategory(id: 'healthy', name: 'Bowls', iconEmoji: '🥗'),
    CuisineCategory(id: 'dessert', name: 'Desserts', iconEmoji: '🍰'),
    CuisineCategory(id: 'asian', name: 'Asian Wok', iconEmoji: '🍜'),
    CuisineCategory(id: 'rolls', name: 'Rolls & Wraps', iconEmoji: '🌯'),
  ];

  static final List<Restaurant> _sampleRestaurants = [
    const Restaurant(
      id: 'res_001',
      name: 'The Royal Biryani Darbar',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
      cuisines: ['Hyderabadi', 'Awadhi', 'Biryani', 'Kebabs'],
      rating: 4.8,
      reviewCount: 1420,
      deliveryTimeMinutes: 22,
      distanceKm: 2.1,
      priceForTwo: Money(45000), // ₹450
      isPureVeg: false,
      offers: ['FLAT ₹100 OFF', 'FREE DELIVERY'],
    ),
    const Restaurant(
      id: 'res_002',
      name: 'Truffle & Brioche Burger Co.',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
      cuisines: ['Gourmet Burgers', 'Burger', 'Shakes', 'Fries'],
      rating: 4.7,
      reviewCount: 980,
      deliveryTimeMinutes: 18,
      distanceKm: 1.6,
      priceForTwo: Money(50000), // ₹500
      isPureVeg: false,
      offers: ['20% OFF UP TO ₹80'],
    ),
    const Restaurant(
      id: 'res_003',
      name: 'Artisan Woodfire Pizzeria',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
      cuisines: ['Neapolitan Pizza', 'Pizza', 'Pasta', 'Italian'],
      rating: 4.9,
      reviewCount: 2150,
      deliveryTimeMinutes: 25,
      distanceKm: 3.2,
      priceForTwo: Money(65000), // ₹650
      isPureVeg: false,
      offers: ['FREE GARLIC BREAD'],
    ),
    const Restaurant(
      id: 'res_004',
      name: 'Shree Krishna Shuddh Shakahari',
      imageUrl:
          'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800',
      cuisines: ['South Indian', 'North Indian', 'Healthy', 'Thali'],
      rating: 4.6,
      reviewCount: 3100,
      deliveryTimeMinutes: 15,
      distanceKm: 1.2,
      priceForTwo: Money(25000), // ₹250
      isPureVeg: true,
      offers: ['PURE VEG SPECIAL'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> _getFilteredRestaurants() {
    final query = _searchController.text.trim().toLowerCase();

    return _sampleRestaurants.where((r) {
      if (_pureVegOnly && !r.isPureVeg) return false;
      if (_fastDeliveryOnly && r.deliveryTimeMinutes > 20) return false;
      if (_topRatedOnly && r.rating < 4.8) return false;

      // Filter by cuisine category
      if (_selectedCuisineId != 'all') {
        final match = r.cuisines.any(
          (c) => c.toLowerCase().contains(_selectedCuisineId.toLowerCase()),
        );
        if (!match) return false;
      }

      // Filter by text search query
      if (query.isNotEmpty) {
        final matchesName = r.name.toLowerCase().contains(query);
        final matchesCuisine = r.cuisines.any((c) => c.toLowerCase().contains(query));
        if (!matchesName && !matchesCuisine) return false;
      }

      return true;
    }).toList();
  }

  void _showAddressModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.all(ZestySpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Delivery Location',
                    style: TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: ZestyColors.textMuted),
                    onPressed: () => Navigator.pop(modalCtx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _addressTile(
                title: 'Home',
                address: '12th Main, Indiranagar, Bengaluru',
                isSelected: _selectedAddress.contains('Indiranagar'),
                onTap: () {
                  setState(() => _selectedAddress = '12th Main, Indiranagar, Bengaluru');
                  Navigator.pop(modalCtx);
                },
              ),
              _addressTile(
                title: 'Work / Office',
                address: 'Bagmane Tech Park, CV Raman Nagar, Bengaluru',
                isSelected: _selectedAddress.contains('Bagmane'),
                onTap: () {
                  setState(() => _selectedAddress = 'Bagmane Tech Park, CV Raman Nagar, Bengaluru');
                  Navigator.pop(modalCtx);
                },
              ),
              _addressTile(
                title: 'Other / Gym',
                address: '100ft Road, Defence Colony, Indiranagar',
                isSelected: _selectedAddress.contains('Defence'),
                onTap: () {
                  setState(() => _selectedAddress = '100ft Road, Defence Colony, Indiranagar');
                  Navigator.pop(modalCtx);
                },
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(modalCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pinning current GPS coordinates...')),
                  );
                },
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Use Current GPS Location'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _addressTile({
    required String title,
    required String address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? ZestyColors.primary.withValues(alpha: 0.12)
            : ZestyColors.glassPill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZestyRadius.md),
          side: BorderSide(
            color:
                isSelected ? ZestyColors.primaryAmber : ZestyColors.glassBorder,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            Icons.location_on_rounded,
            color: isSelected ? ZestyColors.primary : ZestyColors.textMuted,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: ZestyColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            address,
            style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle_rounded,
                  color: ZestyColors.primary, size: 20)
              : null,
        ),
      ),
    );
  }

  void _showNotificationsModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.all(ZestySpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications & Offers',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _notificationItem(
                icon: Icons.local_offer_rounded,
                color: ZestyColors.secondary,
                title: 'FLAT ₹125 OFF Activated',
                subtitle: 'Use coupon code ZESTYFEAST on all gourmet restaurants',
                time: '10 mins ago',
              ),
              _notificationItem(
                icon: Icons.delivery_dining_rounded,
                color: ZestyColors.primary,
                title: 'Lightning Fleet in your Area',
                subtitle: 'Deliveries to Indiranagar are currently averaging 19 mins!',
                time: '1 hour ago',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(color: ZestyColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildDiscoverTab(),
            _buildFavoritesTab(),
            _buildOrdersTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  // ================= TAB 0: DISCOVER =================
  Widget _buildDiscoverTab() {
    final filteredRestaurants = _getFilteredRestaurants();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Top Location & Brand Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZestySpacing.md,
              vertical: ZestySpacing.sm,
            ),
            child: _buildTopBar(context),
          ),
        ),

        // 2. Search Pill Input
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZestySpacing.md,
              vertical: ZestySpacing.xs,
            ),
            child: _buildSearchBar(),
          ),
        ),

        // 3. Promotional Hero Card (Lightning Delivery)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ZestySpacing.md,
              ZestySpacing.md,
              ZestySpacing.md,
              ZestySpacing.xs,
            ),
            child: _buildPromoHero(),
          ),
        ),

        // 4. Cuisine Categories Horizontal Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: ZestySpacing.md),
            child: _buildCuisineSelector(),
          ),
        ),

        // 5. Quick Filter Pills (Veg, Fast Delivery, 4.0+)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZestySpacing.md,
              vertical: ZestySpacing.xs,
            ),
            child: _buildFilterPills(),
          ),
        ),

        // 6. Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ZestySpacing.md,
              ZestySpacing.lg,
              ZestySpacing.md,
              ZestySpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Curated for You',
                  style: TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${filteredRestaurants.length} kitchens near you',
                  style: const TextStyle(
                    color: ZestyColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 7. Restaurant Listing Cards
        if (filteredRestaurants.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: ZestyColors.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'No matching kitchens found',
                      style: TextStyle(color: ZestyColors.textLight, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedCuisineId = 'all';
                          _pureVegOnly = false;
                          _fastDeliveryOnly = false;
                          _topRatedOnly = false;
                        });
                      },
                      child: const Text('Reset All Filters'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: ZestySpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final restaurant = filteredRestaurants[index];
                  final isFav = _favoriteRestaurantIds.contains(restaurant.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ZestySpacing.md),
                    child: _RestaurantCard(
                      restaurant: restaurant,
                      isFavorite: isFav,
                      onFavoriteToggle: () {
                        setState(() {
                          if (isFav) {
                            _favoriteRestaurantIds.remove(restaurant.id);
                          } else {
                            _favoriteRestaurantIds.add(restaurant.id);
                          }
                        });
                      },
                    ),
                  );
                },
                childCount: filteredRestaurants.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ================= TAB 1: FAVORITES =================
  Widget _buildFavoritesTab() {
    final favList = _sampleRestaurants
        .where((r) => _favoriteRestaurantIds.contains(r.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(ZestySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Favorites',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${favList.length} kitchens in your quick-order list',
            style: const TextStyle(color: ZestyColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (favList.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No favorites saved yet. Tap the heart icon on any kitchen to save it here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ZestyColors.textMuted),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: favList.length,
                itemBuilder: (context, index) {
                  final r = favList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _RestaurantCard(
                      restaurant: r,
                      isFavorite: true,
                      onFavoriteToggle: () {
                        setState(() {
                          _favoriteRestaurantIds.remove(r.id);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ================= TAB 2: ORDERS =================
  Widget _buildOrdersTab() {
    return Padding(
      padding: const EdgeInsets.all(ZestySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Orders',
            style: TextStyle(
              color: ZestyColors.textLight,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Live deliveries & past feasts',
            style: TextStyle(color: ZestyColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Active Order Card
                ZestyGlassCard(
                  onTap: () => context.push('/orders/ord_live_8f2c'),
                  borderColor: ZestyColors.primaryAmber.withValues(alpha: 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ZestyColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '● PREPARING NOW',
                              style: TextStyle(
                                color: ZestyColors.primaryAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Text(
                            'ETA ~22 mins',
                            style: TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The Royal Biryani Darbar',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1x Dum Gosht Biryani • 1x Zafrani Phirni',
                        style: TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '₹648 • Paid via Razorpay',
                            style: TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          FilledButton(
                            onPressed: () => context.push('/tracking/ord_live_8f2c'),
                            style: FilledButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Track Live ➔', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Past Order Card
                ZestyGlassCard(
                  onTap: () => context.push('/orders/ord_past_woodfire_1'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ZestyColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '✓ DELIVERED',
                              style: TextStyle(
                                color: ZestyColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Text(
                            'Oct 9, 8:42 PM',
                            style: TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Artisan Woodfire Pizzeria',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1x Neapolitan Margherita • 1x Garlic Bread',
                        style: TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '₹682',
                            style: TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.push('/restaurant/res_003'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              side: const BorderSide(color: ZestyColors.primaryAmber),
                            ),
                            child: const Text(
                              'Re-order',
                              style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 3: PROFILE =================
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(ZestySpacing.md),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Profile Header Card
          ZestyGlassCard(
            padding: const EdgeInsets.all(ZestySpacing.lg),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: ZestyColors.primary,
                  child: Text(
                    'AS',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aarav Sharma',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '+91 98765 43210',
                        style: TextStyle(color: ZestyColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ZestyColors.primaryAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '⚡ ZESTY GOLD MEMBER',
                          style: TextStyle(
                            color: ZestyColors.primaryAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Items
          _profileItem(Icons.location_on_outlined, 'Saved Addresses', () => context.push('/addresses')),
          _profileItem(Icons.credit_card_outlined, 'Payment Modes & UPI', () => context.push('/payments')),
          _profileItem(Icons.local_offer_outlined, 'Coupons & Wallet', () => context.push('/wallet')),
          _profileItem(Icons.support_agent_rounded, '24x7 Customer Support', () => context.push('/support')),
          _profileItem(Icons.settings_outlined, 'Preferences & Settings', () => context.push('/settings')),
          _profileItem(Icons.hub_rounded, '4-in-1 Ecosystem Portals (Partner / Fleet / Admin)', () => context.push('/ecosystem')),
          _profileItem(Icons.logout_rounded, 'Log Out', () => context.go('/auth')),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: ZestyColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZestyRadius.md),
          side: const BorderSide(color: ZestyColors.glassBorder),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: ZestyColors.primaryAmber, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: ZestyColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: ZestyColors.textMuted),
        ),
      ),
    );
  }

  // ================= COMMON WIDGETS =================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Location Pin + Address Selector (Tap opens modal)
        Expanded(
          child: GestureDetector(
            onTap: _showAddressModal,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: ZestyColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Home',
                      style: TextStyle(
                        color: ZestyColors.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ZestyColors.primary.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ZestyColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Brand Badge Cloche
        const ZestyBrandLogo(size: 38, showText: false),
        const SizedBox(width: 10),

        // Notifications Bell
        GestureDetector(
          onTap: _showNotificationsModal,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZestyColors.glassPill,
              shape: BoxShape.circle,
              border: Border.all(color: ZestyColors.glassBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: ZestyColors.textLight,
                  size: 20,
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: ZestyColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ZestyGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      borderRadius: ZestyRadius.sheet,
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: ZestyColors.primaryAmber,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: ZestyColors.textLight,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Search 'Biryani', 'Truffle Burger'...",
                hintStyle: const TextStyle(
                  color: ZestyColors.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: ZestyColors.textMuted),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: ZestyColors.glassBorder,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.manage_search_rounded, color: ZestyColors.primaryAmber, size: 22),
            tooltip: 'Full Search & Filters',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoHero() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ZestyRadius.card),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C1611),
            Color(0xFF1A1215),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: ZestyColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ZestyColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ZestySpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ZestyColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ZestyRadius.chip),
                  ),
                  child: const Text(
                    '⚡ LIGHTNING GOURMET • < 25 MINS',
                    style: TextStyle(
                      color: ZestyColors.primaryAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'FLAT ₹125 OFF',
                  style: TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Use code ZESTYFEAST on top-rated kitchens',
                  style: TextStyle(
                    color: ZestyColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to top restaurant
                    context.push('/restaurant/res_001');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZestyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ZestyRadius.chip),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Order Now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ZestyBrandLogo(size: 74, showText: false),
        ],
      ),
    );
  }

  Widget _buildCuisineSelector() {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ZestySpacing.md),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _cuisines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cuisine = _cuisines[index];
          final isSelected = cuisine.id == _selectedCuisineId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCuisineId = isSelected ? 'all' : cuisine.id;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ZestyColors.primary
                        : ZestyColors.darkCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ZestyColors.primaryAmber
                          : ZestyColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: ZestyColors.primary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cuisine.iconEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cuisine.name,
                  style: TextStyle(
                    color: isSelected
                        ? ZestyColors.primaryAmber
                        : ZestyColors.textLight,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Pure Veg Filter
          ZestyGlassPill(
            isSelected: _pureVegOnly,
            onTap: () {
              setState(() {
                _pureVegOnly = !_pureVegOnly;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ZestyVegBadge(size: 12),
                const SizedBox(width: 6),
                Text(
                  'Pure Veg',
                  style: TextStyle(
                    color: _pureVegOnly
                        ? Colors.white
                        : ZestyColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Fast Delivery
          ZestyGlassPill(
            isSelected: _fastDeliveryOnly,
            onTap: () {
              setState(() {
                _fastDeliveryOnly = !_fastDeliveryOnly;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: ZestyColors.primaryAmber,
                ),
                const SizedBox(width: 4),
                Text(
                  'Fast Delivery (<20m)',
                  style: TextStyle(
                    color: _fastDeliveryOnly ? Colors.white : ZestyColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Rating 4.8+
          ZestyGlassPill(
            isSelected: _topRatedOnly,
            onTap: () {
              setState(() {
                _topRatedOnly = !_topRatedOnly;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Top Rated (4.8+)',
                  style: TextStyle(
                    color: _topRatedOnly ? Colors.white : ZestyColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, size: 14, color: ZestyColors.ratingGold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE6161317), // 90% dark obsidian glass
        border: Border(top: BorderSide(color: ZestyColors.glassBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.explore_rounded, 'Discover'),
          _navItem(1, Icons.favorite_rounded, 'Favorites'),
          _navItem(2, Icons.shopping_bag_outlined, 'Orders'),
          _navItem(3, Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? ZestyColors.primary : ZestyColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? ZestyColors.primary : ZestyColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single restaurant card widget matching the Stitch layout
class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return ZestyGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: ZestyRadius.card,
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image Header with Offer Badge & ETA
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ZestyRadius.card),
                ),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: ZestyColors.darkCard,
                  child: Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF262024),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: ZestyColors.textMuted,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient Overlay on Image
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xB3100E10),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorite Heart Button (Top Right)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? const Color(0xFFFF4B4B) : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Offer Pill on Image
              if (restaurant.offers.isNotEmpty)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ZestyColors.primary,
                      borderRadius: BorderRadius.circular(ZestyRadius.xs),
                    ),
                    child: Text(
                      restaurant.offers.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // ETA & Distance Chip
              Positioned(
                bottom: 12,
                right: 12,
                child: ZestyEtaChip(
                  etaText: restaurant.etaDisplay,
                  distanceText: restaurant.distanceDisplay,
                ),
              ),
            ],
          ),

          // Details Row
          Padding(
            padding: const EdgeInsets.all(ZestySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ZestyRatingBadge(
                      rating: restaurant.rating,
                      reviewCount: restaurant.reviewCount,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (restaurant.isPureVeg) ...[
                      const ZestyVegBadge(size: 13),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        '${restaurant.cuisinesDisplay} • ${restaurant.priceForTwo.format()} for two',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ZestyColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
