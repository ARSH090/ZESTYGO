import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_portal/app/app.dart';

void main() {
  testWidgets('app boots to the bootstrap screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZestyGoApp()));
    await tester.pumpAndSettle();
    expect(find.text('ZestyGo Restaurant Portal'), findsOneWidget);
  });
}
