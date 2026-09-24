import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/app/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const KidarehApp());
    await tester.pumpAndSettle();

    expect(find.text('کی‌داره؟'), findsOneWidget);
    expect(find.text('ببین کی داره، حضوری بگیر'), findsOneWidget);
  });
}
