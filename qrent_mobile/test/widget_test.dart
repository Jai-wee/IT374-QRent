import 'package:flutter_test/flutter_test.dart';
import 'package:qrent_mobile/main.dart';

void main() {
  testWidgets('QRent App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QRentApp());
    expect(find.text('QRent'), findsOneWidget);
  });
}
