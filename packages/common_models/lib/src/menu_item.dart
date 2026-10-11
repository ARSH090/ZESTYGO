import 'money.dart';

/// Menu item entity with Indian veg/non-veg flags and pricing.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    this.isVeg = true,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.isBestseller = false,
    this.rating,
    this.ratingCount,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final Money price;
  final bool isVeg;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final bool isBestseller;
  final double? rating;
  final int? ratingCount;
}
