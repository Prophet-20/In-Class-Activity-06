import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smiley_face/main.dart';

SmileyPainter currentPainter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((widget) => widget.painter)
    .whereType<SmileyPainter>()
    .single;

void main() {
  test('Mood bands include the boundary values', () {
    expect(moodColor(.349), const Color(0xFF90CAF9));
    expect(moodColor(.35), const Color(0xFFFFEB3B));
    expect(moodColor(.7), const Color(0xFFFFEB3B));
    expect(moodColor(.701), const Color(0xFFFFB74D));
  });

  test('Every mutable painter input triggers repaint', () {
    final original = SmileyPainter(mood: .8);
    expect(SmileyPainter(mood: .8).shouldRepaint(original), isFalse);
    for (final changed in [
      SmileyPainter(mood: .2),
      SmileyPainter(mood: .8, faceType: FaceType.sleepy),
      SmileyPainter(mood: .8, faceColor: Colors.green),
      SmileyPainter(mood: .8, eyeRadius: .15),
      SmileyPainter(mood: .8, eyeGap: .5),
      SmileyPainter(mood: .8, blush: true),
      SmileyPainter(mood: .8, hat: true),
      SmileyPainter(mood: .8, bullseye: true),
    ]) {
      expect(changed.shouldRepaint(original), isTrue);
    }
  });

  for (final size in [
    const Size(393, 852),
    const Size(852, 393),
    const Size(320, 568),
  ]) {
    testWidgets('Controls and gestures work at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const SmileyApp());
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Surprised'));
      await tester.pumpAndSettle();
      expect(currentPainter(tester).faceType, FaceType.surprised);
      await tester.tap(find.byKey(const ValueKey('faceCanvas')));
      await tester.pumpAndSettle();
      expect(currentPainter(tester).faceType, FaceType.classic);
      final oldColor = currentPainter(tester).faceColor;
      await tester.longPress(find.byKey(const ValueKey('faceCanvas')));
      await tester.pumpAndSettle();
      expect(currentPainter(tester).faceColor, isNot(oldColor));
      expect(find.byType(SnackBar), findsOneWidget);
      final mood = find.byKey(const ValueKey('mood'));
      await tester.ensureVisible(mood);
      await tester.drag(mood, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(currentPainter(tester).mood, closeTo(0, .01));
      expect(currentPainter(tester).faceColor, moodColor(0));
      expect(tester.takeException(), isNull);
    });
  }
}
