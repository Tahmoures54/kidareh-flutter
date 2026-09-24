import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidareh_flutter/app/app.dart';
import 'package:kidareh_flutter/features/auth/auth_controller.dart';

class _TestAuthController extends AuthController {
  @override
  Future<Map<String, dynamic>?> build() async => null;
}

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_TestAuthController.new),
        ],
        child: const KidarehApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('کی‌داره؟'), findsOneWidget);
    expect(find.text('ببین کی داره، حضوری بگیر'), findsOneWidget);
  });
}
