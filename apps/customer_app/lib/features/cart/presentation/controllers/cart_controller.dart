import 'package:common_models/common_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of adding an item when another restaurant's items are in the cart.
enum AddToCartResult {
  added,
  restaurantConflict,
}

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart());

  /// Attempts to add an item. If an item from a different restaurant exists,
  /// returns [AddToCartResult.restaurantConflict] without altering the cart.
  AddToCartResult addItem({
    required Restaurant restaurant,
    required MenuItem item,
  }) {
    if (state.isNotEmpty && state.restaurantId != restaurant.id) {
      return AddToCartResult.restaurantConflict;
    }

    final existingIndex = state.items.indexWhere((i) => i.item.id == item.id);
    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      updatedItems = List.from(state.items);
      updatedItems[existingIndex] = current.copyWith(
        quantity: current.quantity + 1,
      );
    } else {
      updatedItems = [
        ...state.items,
        CartItem(item: item, quantity: 1),
      ];
    }

    state = state.copyWith(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: updatedItems,
    );

    return AddToCartResult.added;
  }

  /// Decrements item quantity, removing it when reaching 0.
  void removeItem(String itemId) {
    if (state.isEmpty) return;

    final existingIndex = state.items.indexWhere((i) => i.item.id == itemId);
    if (existingIndex < 0) return;

    final current = state.items[existingIndex];
    final List<CartItem> updatedItems = List.from(state.items);

    if (current.quantity > 1) {
      updatedItems[existingIndex] = current.copyWith(
        quantity: current.quantity - 1,
      );
    } else {
      updatedItems.removeAt(existingIndex);
    }

    if (updatedItems.isEmpty) {
      state = const Cart();
    } else {
      state = state.copyWith(items: updatedItems);
    }
  }

  /// Clears the cart completely and forces adding a new restaurant's item.
  void replaceCartWithItem({
    required Restaurant restaurant,
    required MenuItem item,
  }) {
    state = Cart(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: [CartItem(item: item, quantity: 1)],
    );
  }

  void clear() {
    state = const Cart();
  }

  int getItemQuantity(String itemId) {
    final match = state.items.where((i) => i.item.id == itemId);
    return match.isEmpty ? 0 : match.first.quantity;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});
