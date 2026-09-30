// In-Class Activity 06 — Drawing with Flutter
// Student: Blake Cantave
// Date: September 30, 2026

import 'dart:math' show Random, pi;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised }

extension FaceName on FaceType {
  String get label => switch (this) {
    FaceType.classic => 'Classic',
    FaceType.sleepy => 'Sleepy',
    FaceType.surprised => 'Surprised',
  };
}

Color moodColor(double mood) => mood < .35
    ? const Color(0xFF90CAF9)
    : mood <= .7
    ? const Color(0xFFFFEB3B)
    : const Color(0xFFFFB74D);

String moodLabel(double mood) => mood < .35
    ? 'Sad'
    : mood <= .7
    ? 'Content'
    : 'Beaming';

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smiley Painter Lab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const DrawingPlayground(),
  );
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});
  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  final random = Random();
  double mood = .8;
  double eyeRadius = .10;
  double eyeGap = .35;
  FaceType faceType = FaceType.classic;
  Color? customColor;
  bool blush = false;
  bool hat = false;
  bool bullseye = false;

  void feedback(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void cycleFace() {
    setState(() {
      bullseye = false;
      faceType = FaceType.values[(faceType.index + 1) % FaceType.values.length];
    });
    feedback('Face changed to ${faceType.label}');
  }

  void randomize() {
    setState(() {
      mood = random.nextDouble();
      customColor = HSVColor.fromAHSV(
        1,
        random.nextDouble() * 360,
        .45,
        1,
      ).toColor();
      bullseye = false;
    });
    feedback('Random mood: ${mood.toStringAsFixed(2)} • New face color');
  }

  Widget slider(
    String title,
    String id,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      Slider(
        key: ValueKey(id),
        value: value,
        min: min,
        max: max,
        label: value.toStringAsFixed(2),
        onChanged: onChanged,
      ),
    ],
  );

  Widget controls() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final type in FaceType.values)
              ChoiceChip(
                label: Text(type.label),
                selected: faceType == type,
                onSelected: (_) => setState(() {
                  faceType = type;
                  bullseye = false;
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        slider(
          'Mood: ${mood.toStringAsFixed(2)} · ${moodLabel(mood)}',
          'mood',
          mood,
          0,
          1,
          (value) => setState(() {
            mood = value;
            customColor = null;
          }),
        ),
        slider(
          'Eye radius: ${(eyeRadius * 100).round()}% of face radius',
          'eyeRadius',
          eyeRadius,
          .06,
          .16,
          (value) => setState(() => eyeRadius = value),
        ),
        slider(
          'Eye gap: ${(eyeGap * 100).round()}% from center',
          'eyeGap',
          eyeGap,
          .25,
          .5,
          (value) => setState(() => eyeGap = value),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('Blush'),
              selected: blush,
              onSelected: (value) => setState(() => blush = value),
            ),
            FilterChip(
              label: const Text('Hat'),
              selected: hat,
              onSelected: (value) => setState(() => hat = value),
            ),
            FilterChip(
              label: const Text('Bullseye'),
              selected: bullseye,
              onSelected: (value) => setState(() => bullseye = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: randomize,
          icon: const Icon(Icons.shuffle),
          label: const Text('Randomize mood & color'),
        ),
        TextButton(
          onPressed: () => setState(() {
            mood = .8;
            eyeRadius = .1;
            eyeGap = .35;
            faceType = FaceType.classic;
            customColor = null;
            blush = false;
            hat = false;
            bullseye = false;
          }),
          child: const Text('Reset'),
        ),
      ],
    ),
  );

  Widget drawing() => Column(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) => Semantics(
              label:
                  '${faceType.label} face, ${moodLabel(mood)}. Tap to cycle; long press to randomize.',
              button: true,
              child: GestureDetector(
                key: const ValueKey('faceCanvas'),
                behavior: HitTestBehavior.opaque,
                onTap: cycleFace,
                onLongPress: randomize,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: SmileyPainter(
                    mood: mood,
                    faceType: faceType,
                    faceColor: customColor ?? moodColor(mood),
                    eyeRadius: eyeRadius,
                    eyeGap: eyeGap,
                    blush: blush,
                    hat: hat,
                    bullseye: bullseye,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Tap to cycle • Hold to randomize',
          style: TextStyle(fontSize: 12),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Smiley Painter Lab')),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > constraints.maxHeight) {
            return Row(
              children: [
                Expanded(child: drawing()),
                Expanded(child: controls()),
              ],
            );
          }
          return Column(
            children: [
              Expanded(flex: 5, child: drawing()),
              Expanded(flex: 6, child: controls()),
            ],
          );
        },
      ),
    ),
  );
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    this.faceType = FaceType.classic,
    Color? faceColor,
    this.eyeRadius = .1,
    this.eyeGap = .35,
    this.blush = false,
    this.hat = false,
    this.bullseye = false,
  }) : faceColor = faceColor ?? moodColor(mood);

  final double mood, eyeRadius, eyeGap;
  final FaceType faceType;
  final Color faceColor;
  final bool blush, hat, bullseye;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .4;
    if (r <= 0) return;
    final ink = Paint()..color = const Color(0xFF172033);
    final stroke = Paint()
      ..color = ink.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .035
      ..strokeCap = StrokeCap.round;

    // Largest circle first: smaller circles remain visible on top.
    if (bullseye) {
      canvas.drawCircle(c, r, Paint()..color = Colors.indigo);
      canvas.drawCircle(c, r * .65, Paint()..color = Colors.amber);
      canvas.drawCircle(c, r * .3, Paint()..color = Colors.redAccent);
      return;
    }

    // Layer order: fill, border, eyes, mouth, blush, accessories.
    canvas.drawCircle(c, r, Paint()..color = faceColor);
    canvas.drawCircle(c, r, stroke);
    for (final direction in [-1, 1]) {
      final eye = c + Offset(direction * r * eyeGap, -r * .22);
      if (faceType == FaceType.sleepy) {
        canvas.drawArc(
          Rect.fromCenter(center: eye, width: r * .26, height: r * .15),
          0,
          pi,
          false,
          stroke,
        );
      } else {
        final er = r * eyeRadius * (faceType == FaceType.surprised ? 1.35 : 1);
        canvas.drawCircle(eye, er, ink);
        canvas.drawCircle(
          eye + Offset(-er * .25, -er * .25),
          er * .25,
          Paint()..color = Colors.white,
        );
      }
    }

    if (faceType == FaceType.surprised) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(0, r * .40),
          width: r * .30,
          height: r * (.32 + mood * .15),
        ),
        ink,
      );
    } else {
      final sad = mood < .35;
      final depth = sad
          ? .18 + (.35 - mood) * .8
          : mood <= .7
          ? .08 + (mood - .35) * .7
          : .35 + (mood - .7) * 1.5;
      final rect = Rect.fromCenter(
        center: c + Offset(0, r * (sad ? .50 : .22)),
        width: r * (faceType == FaceType.sleepy ? .65 : 1.05),
        height: r * depth * (faceType == FaceType.sleepy ? .6 : 1),
      );
      // Angles are radians; positive sweeps travel clockwise.
      canvas.drawArc(rect, (sad ? 1.15 : .15) * pi, .70 * pi, false, stroke);
    }

    if (blush) {
      for (final direction in [-1, 1]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(direction * r * .62, r * .20),
            width: r * .28,
            height: r * .14,
          ),
          Paint()..color = const Color(0x99F06292),
        );
      }
    }
    if (hat) {
      // Draw last so the hat covers the top of the face.
      canvas.drawRect(
        Rect.fromLTWH(c.dx - r * .45, c.dy - r * 1.15, r * .9, r * .45),
        ink,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(c.dx - r * .65, c.dy - r * .76, r * 1.3, r * .12),
          Radius.circular(r * .04),
        ),
        ink,
      );
      canvas.drawLine(
        c + Offset(-r * .4, -r * .84),
        c + Offset(r * .4, -r * .84),
        Paint()
          ..color = Colors.indigoAccent
          ..strokeWidth = r * .06,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.faceType != faceType ||
      oldDelegate.faceColor != faceColor ||
      oldDelegate.eyeRadius != eyeRadius ||
      oldDelegate.eyeGap != eyeGap ||
      oldDelegate.blush != blush ||
      oldDelegate.hat != hat ||
      oldDelegate.bullseye != bullseye;
}
