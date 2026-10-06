import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pulsepay_app/main.dart';

void main() {
  // No mock handler means flutter_secure_storage's channel call never
  // completes in the test VM, so the app just hangs on AuthLoading.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets('App boots to the login screen when unauthenticated', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PulsePayApp()));

    // Not pumpAndSettle(): the auth-loading state briefly renders a
    // CircularProgressIndicator, which animates indefinitely and would make
    // pumpAndSettle time out waiting for animations to stop.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('PulsePay'), findsWidgets);
    expect(find.text('Log in'), findsOneWidget);
  });
}
