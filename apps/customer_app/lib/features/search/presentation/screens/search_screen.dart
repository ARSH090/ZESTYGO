import 'package:common_models/common_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../restaurant/data/restaurant_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _pureVegOnly = false;
  String _query = '';

  final List<String> _trending = [
    'Hyderabadi Biryani',
    'Truffle Burger',
    'Woodfire Pizza',
    'Garlic Bread',
    'Thali',
    'Gulab Jamun',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _query = _controller.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSearchResults() {
    if (_query.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    // 1. Check restaurants
    for (final r in RestaurantRepository.sampleRestaurants) {
      if (_pureVegOnly && !r.isPureVeg) continue;
      final matchesName = r.name.toLowerCase().contains(_query);
      final matchesCuisine =
          r.cuisines.any((String c) => c.toLowerCase().contains(_query));
      if (matchesName || matchesCuisine) {
        results.add({
          'type': 'restaurant',
          'restaurant': r,
        });
      }
    }

    // 2. Check menu items
    for (final r in RestaurantRepository.sampleRestaurants) {
      final items = RestaurantRepository.getMenuForRestaurant(r.id);
      for (final item in items) {
        if (_pureVegOnly && !item.isVeg) continue;
        if (item.name.toLowerCase().contains(_query) ||
            item.description.toLowerCase().contains(_query) ||
            item.category.toLowerCase().contains(_query)) {
          results.add({
            'type': 'dish',
            'dish': item,
            'restaurant': r,
          });
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _getSearchResults();

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B171D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ZestyColors.glassBorder),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: ZestyColors.textLight, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search 'Biryani', 'Burger', 'Pizza'...",
              hintStyle: const TextStyle(color: ZestyColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: ZestyColors.primaryAmber, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: ZestyColors.textMuted),
                      onPressed: () => _controller.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Pure Veg Only'),
                  selected: _pureVegOnly,
                  selectedColor: Colors.green.withValues(alpha: 0.25),
                  backgroundColor: ZestyColors.glassPill,
                  labelStyle: TextStyle(
                    color: _pureVegOnly ? Colors.greenAccent : ZestyColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  avatar: Icon(
                    Icons.circle,
                    size: 10,
                    color: _pureVegOnly ? Colors.greenAccent : Colors.grey,
                  ),
                  onSelected: (val) => setState(() => _pureVegOnly = val),
                ),
              ],
            ),
          ),

          Expanded(
            child: _query.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Text(
                        'Trending Gourmet Searches',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _trending.map((t) {
                          return ActionChip(
                            label: Text(t),
                            backgroundColor: ZestyColors.glassPill,
                            labelStyle: const TextStyle(color: ZestyColors.textLight, fontSize: 12),
                            onPressed: () {
                              _controller.text = t;
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: ZestyColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No matches for "$_query"',
                              style: const TextStyle(color: ZestyColors.textLight, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          if (item['type'] == 'restaurant') {
                            final r = item['restaurant'] as Restaurant;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ZestyGlassCard(
                                onTap: () => context.push('/restaurant/${r.id}'),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        r.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.name,
                                            style: const TextStyle(
                                              color: ZestyColors.textLight,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            r.cuisinesDisplay,
                                            style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: ZestyColors.textMuted),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final d = item['dish'] as MenuItem;
                            final r = item['restaurant'] as Restaurant;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ZestyGlassCard(
                                onTap: () => context.push('/restaurant/${r.id}'),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: d.isVeg ? Colors.greenAccent : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d.name,
                                            style: const TextStyle(
                                              color: ZestyColors.textLight,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'from ${r.name}',
                                            style: const TextStyle(color: ZestyColors.primaryAmber, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      d.price.format(),
                                      style: const TextStyle(
                                        color: ZestyColors.textLight,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
