import 'package:customer_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the animated splash screen and renders branding',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZestyGoApp()));
    await tester.pump();

    // Verifies brand typography and tagline on splash
    expect(find.text('Zesty', findRichText: true), findsOneWidget);
    expect(find.text('Go', findRichText: true), findsOneWidget);
    expect(find.text('GOURMET FOOD • LIGHTNING DELIVERY'), findsOneWidget);
  });

  testWidgets('tap explore directly navigates to home discovery screen',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZestyGoApp()));
    await tester.pump();

    // Tap skip/explore directly
    final exploreBtn = find.text('Explore directly →');
    expect(exploreBtn, findsOneWidget);
    await tester.tap(exploreBtn);
    await tester.pumpAndSettle();

    // Verify Home Discovery screen elements
    expect(find.text('Curated for You'), findsOneWidget);
    expect(find.text('FLAT ₹125 OFF'), findsOneWidget);
    expect(find.text('All Dishes'), findsOneWidget);
  });
}
