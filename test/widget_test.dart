
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/main.dart';

void main() {
  testWidgets('TrackPense welcome screen test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TrackPenseApp());

    expect(find.text('TrackPense'), findsOneWidget);
    expect(
      find.text('Track your money. Manage your future.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
  });
}
