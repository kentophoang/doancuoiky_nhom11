import 'package:flutter_test/flutter_test.dart';
import 'package:doancuoiky_test2/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // MyApp không yêu cầu tham số showOnboarding
    await tester.pumpWidget(const MyApp());
  });
}
