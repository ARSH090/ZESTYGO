/// Mirrors functions/src/orders/stateMachine.ts. The server is the source of truth.
enum OrderStatus {
  created('CREATED'),
  paymentPending('PAYMENT_PENDING'),
  paymentFailed('PAYMENT_FAILED'),
  expired('EXPIRED'),
  confirmed('CONFIRMED'),
  restaurantAccepted('RESTAURANT_ACCEPTED'),
  rejected('REJECTED'),
  preparing('PREPARING'),
  readyForPickup('READY_FOR_PICKUP'),
  pickedUp('PICKED_UP'),
  outForDelivery('OUT_FOR_DELIVERY'),
  delivered('DELIVERED'),
  cancellationRequested('CANCELLATION_REQUESTED'),
  cancelled('CANCELLED'),
  deliveryFailed('DELIVERY_FAILED'),
  refundPending('REFUND_PENDING'),
  refunded('REFUNDED');

  const OrderStatus(this.wire);

  /// Value stored in Firestore.
  final String wire;

  static OrderStatus fromWire(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.wire == value,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unknown order status'),
    );
  }

  /// The customer sees the live map only while the partner carries the order.
  bool get showsLiveTracking => this == pickedUp || this == outForDelivery;

  bool get isFinished => this == delivered || this == refunded;
}

enum DeliveryStatus {
  unassigned('UNASSIGNED'),
  offered('OFFERED'),
  assigned('ASSIGNED'),
  atRestaurant('AT_RESTAURANT'),
  pickedUp('PICKED_UP'),
  delivered('DELIVERED'),
  failed('FAILED');

  const DeliveryStatus(this.wire);

  final String wire;

  static DeliveryStatus fromWire(String value) {
    return DeliveryStatus.values.firstWhere(
      (s) => s.wire == value,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unknown delivery status'),
    );
  }
}
