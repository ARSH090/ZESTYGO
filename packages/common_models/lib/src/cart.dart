import 'menu_item.dart';
import 'money.dart';

/// Single item line in the cart with quantity.
class CartItem {
  const CartItem({
    required this.item,
    required this.quantity,
  });

  final MenuItem item;
  final int quantity;

  Money get totalPrice => Money(item.price.paise * quantity);

  CartItem copyWith({int? quantity}) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// In-memory cart constrained to a single restaurant as per ADR 0002.
class Cart {
  const Cart({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
  });

  final String? restaurantId;
  final String? restaurantName;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Money get subtotal => Money(items.fold(0, (sum, i) => sum + i.totalPrice.paise));

  Cart copyWith({
    String? restaurantId,
    String? restaurantName,
    List<CartItem>? items,
  }) {
    return Cart(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
    );
  }
}
