import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/main.dart';

void main() {
  testWidgets('MediTrack smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediTrackApp());

    // Verify app elements
    expect(find.byType(MediTrackApp), findsOneWidget);
  });
}
