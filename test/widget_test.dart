import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/app/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const KidarehApp());
    expect(find.text('کی‌داره؟'), findsOneWidget);
  });
}
