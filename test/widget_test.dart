import 'package:flutter_test/flutter_test.dart';
import 'package:cloudbeats/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CloudBeatsApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CloudBeatsApp());
    expect(find.byType(CloudBeatsApp), findsOneWidget);
  });
}
