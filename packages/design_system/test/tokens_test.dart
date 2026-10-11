import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme builds with Material 3 and the brand primary color', () {
    final theme = buildZestyTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, ZestyColors.primary);
  });
}
