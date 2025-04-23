// lib/widgets/captcha_widget.dart

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CaptchaWidget extends StatefulWidget {
  final Function(bool) onVerified;

  const CaptchaWidget({Key? key, required this.onVerified}) : super(key: key);

  @override
  _CaptchaWidgetState createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  late String _captchaText;
  late ui.Image _captchaImage;
  bool _isVerified = false;

  final TextEditingController _captchaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  @override
  void dispose() {
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() async {
    _captchaText = _randomString(6);
    _captchaImage = await _createCaptchaImage(_captchaText);
    setState(() {});
  }

  String _randomString(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  Future<ui.Image> _createCaptchaImage(String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // Fill background with a random light color
    paint.color = Colors.grey.shade200;
    canvas.drawRect(Rect.fromLTWH(0, 0, 200, 80), paint);

    // Add noise - draw random lines
    paint.color = Colors.grey.shade400;
    Random rnd = Random();
    for (int i = 0; i < 15; i++) {
      canvas.drawLine(
        Offset(rnd.nextDouble() * 200, rnd.nextDouble() * 80),
        Offset(rnd.nextDouble() * 200, rnd.nextDouble() * 80),
        paint,
      );
    }

    // Draw the text with random styles
    for (int i = 0; i < text.length; i++) {
      paint.color = _randomColor();
      final double fontSize = 30 + rnd.nextDouble() * 10;
      final double x = 20 + i * 30 + rnd.nextDouble() * 10;
      final double y = 50 + rnd.nextDouble() * 10;
      final double rotation = (rnd.nextDouble() - 0.5) * 0.4; // Rotate between -0.2 to 0.2 radians

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            color: paint.color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(-10, -20));
      canvas.restore();
    }

    // Add more noise - draw random dots
    for (int i = 0; i < 100; i++) {
      paint.color = _randomColor();
      canvas.drawCircle(
        Offset(rnd.nextDouble() * 200, rnd.nextDouble() * 80),
        1,
        paint,
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 80);
    return img;
  }

  Color _randomColor() {
    Random rnd = Random();
    return Color.fromARGB(
      255,
      rnd.nextInt(100),
      rnd.nextInt(100),
      rnd.nextInt(100),
    );
  }

  void _verifyCaptcha() {
    if (_captchaController.text.trim().toUpperCase() == _captchaText) {
      setState(() {
        _isVerified = true;
      });
      widget.onVerified(true);
    } else {
      setState(() {
        _isVerified = false;
        _generateCaptcha();
        _captchaController.clear();
      });
      widget.onVerified(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect CAPTCHA. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captchaImage != null
            ? CustomPaint(
          size: const Size(200, 80),
          painter: ImagePainter(_captchaImage),
        )
            : const SizedBox(
          width: 200,
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _captchaController,
                decoration: const InputDecoration(
                  labelText: 'Enter CAPTCHA',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _verifyCaptcha(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _generateCaptcha();
                _captchaController.clear();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _verifyCaptcha,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.cover,
    );
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
