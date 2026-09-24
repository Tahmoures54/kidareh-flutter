import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidareh_flutter/app/app.dart';
import 'package:kidareh_flutter/features/auth/auth_controller.dart';

class _TestAuthController extends AuthController {
  @override
  Future<Map<String, dynamic>?> build() async => null;
}

void main() {
  testWidgets('app starts on search', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_TestAuthController.new),
        ],
        child: const KidarehApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('پیدا کردن کالا'), findsOneWidget);
    expect(find.text('جستجو'), findsWidgets);
    expect(find.text('فروشگاه'), findsOneWidget);
    expect(find.text('حساب'), findsOneWidget);
  });
}
