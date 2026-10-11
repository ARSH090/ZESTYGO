import 'money.dart';

/// Restaurant entity shared across Customer App, Restaurant Portal, and Admin Portal.
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisines,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTimeMinutes,
    required this.distanceKm,
    required this.priceForTwo,
    this.isOpen = true,
    this.isPureVeg = false,
    this.offers = const [],
    this.address,
  });

  final String id;
  final String name;
  final String imageUrl;
  final List<String> cuisines;
  final double rating;
  final int reviewCount;
  final int deliveryTimeMinutes;
  final double distanceKm;
  final Money priceForTwo;
  final bool isOpen;
  final bool isPureVeg;
  final List<String> offers;
  final String? address;

  String get etaDisplay => '$deliveryTimeMinutes-${deliveryTimeMinutes + 5} mins';
  String get distanceDisplay => '${distanceKm.toStringAsFixed(1)} km';
  String get cuisinesDisplay => cuisines.join(', ');
}
