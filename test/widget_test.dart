import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tajweed/app.dart';

void main() {
  testWidgets('Shows Arabic home tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TajweedApp());
    await tester.pumpAndSettle();

    expect(find.text('الدروس'), findsOneWidget);
    expect(find.text('التدريب'), findsOneWidget);
    expect(find.text('التحليل'), findsOneWidget);
  });
}
