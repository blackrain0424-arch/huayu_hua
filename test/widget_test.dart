import 'package:flutter_test/flutter_test.dart';
import 'package:huayu_hua/main.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the app shows the map tab by default
    expect(find.text('华语花 · 寻芳中国'), findsOneWidget);

    // Verify bottom navigation tabs exist
    expect(find.text('地图'), findsOneWidget);
    expect(find.text('发现'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
