# Test report

Date: September 30, 2026

## Automated verification

- Flutter 3.47.3 / Dart 3.13.3.
- `flutter analyze`: no issues.
- `flutter test`: all five tests passed.
- Verified mood-color boundaries at 0.35 and 0.70.
- Verified unchanged painter inputs do not request repaint, and each changed input does.
- Tested face buttons, tap-to-cycle, long-press randomization, replacement SnackBar, slider propagation, and lack of layout exceptions at 393×852, 852×393, and 320×568 logical pixels.
- `flutter build apk --release`: succeeded (approximately 45.5 MB).

## Android emulator, installed release APK

Device: emulator-5554; physical resolution 1344×2992, density 480.

- Installed with `adb install -r` and launched as a normal app.
- Portrait: complete drawing and controls visible.
- Landscape: drawing stayed centered and fully visible; controls moved beside it, with lower controls accessible by scrolling.
- Dragged mood to about 0.01: face changed immediately to blue with a frown.
- Tapped the face: Classic → Sleepy → Surprised; eyes and mouth visibly changed.
- Long-pressed the face: mood and face color changed; the new SnackBar replaced the prior face-change message.
- Enabled hat and blush: both appeared above the face.
- Enabled bullseye: three concentric circles appeared.
- Restored the emulator's original automatic-rotation setting after checking both orientations.

Evidence PNGs are in this directory. Tests at iPhone-sized dimensions are Flutter widget tests; no iOS simulator execution is claimed.

## Hot reload

Ran the debug build on the same emulator, performed Flutter hot reload successfully (326 ms), then dragged mood from 0.80 to 0.50. The label, face color, and mouth updated immediately to the yellow soft smile without restarting the app; see `emulator_after_reload.png`.
