import 'package:common_models/common_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('formats paise as rupees', () {
      expect(const Money(51290).format(), '₹512.90');
      expect(const Money(5).format(), '₹0.05');
      expect(const Money(0).format(), '₹0.00');
      expect(const Money(-250).format(), '-₹2.50');
    });

    test('adds, subtracts and compares by value', () {
      expect(const Money(100) + const Money(50), const Money(150));
      expect(const Money(100) - const Money(40), const Money(60));
    });
  });

  group('OrderStatus', () {
    test('round-trips every wire value', () {
      for (final s in OrderStatus.values) {
        expect(OrderStatus.fromWire(s.wire), s);
      }
    });

    test('rejects unknown values', () {
      expect(() => OrderStatus.fromWire('NOPE'), throwsArgumentError);
    });

    test('shows tracking only while a partner carries the order', () {
      expect(OrderStatus.outForDelivery.showsLiveTracking, isTrue);
      expect(OrderStatus.preparing.showsLiveTracking, isFalse);
    });
  });
}
