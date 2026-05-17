import 'dart:math';
import 'package:flutter/material.dart';

class AppCaptchaController {
  VoidCallback? _refreshCallback;
  VoidCallback? _resetCallback;
  bool Function()? _isVerifiedCallback;

  void _bind({
    required VoidCallback refresh,
    required VoidCallback reset,
    required bool Function() isVerified,
  }) {
    _refreshCallback = refresh;
    _resetCallback = reset;
    _isVerifiedCallback = isVerified;
  }

  void refresh() {
    _refreshCallback?.call();
  }

  void reset() {
    _resetCallback?.call();
  }

  bool get isVerified {
    return _isVerifiedCallback?.call() ?? false;
  }
}

class AppCaptchaWidget extends StatefulWidget {
  final AppCaptchaController? controller;
  final ValueChanged<bool> onVerifiedChanged;
  final String title;
  final String hintText;

  const AppCaptchaWidget({
    super.key,
    this.controller,
    required this.onVerifiedChanged,
    this.title = 'Security Verification',
    this.hintText = 'Enter answer',
  });

  @override
  State<AppCaptchaWidget> createState() => _AppCaptchaWidgetState();
}

class _AppCaptchaWidgetState extends State<AppCaptchaWidget> {
  final TextEditingController _answerController = TextEditingController();
  final Random _random = Random();

  String _question = '';
  String _correctAnswer = '';
  bool _isVerified = false;
  String _message = '';
  double _rotationAngle = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _generateCaptcha(notifyParent: false);

    widget.controller?._bind(
      refresh: () => _generateCaptcha(),
      reset: _resetCaptcha,
      isVerified: () => _isVerified,
    );
  }

  void _generateCaptcha({bool notifyParent = true}) {
    final int type = _random.nextInt(4);
    _rotationAngle = (_random.nextDouble() * 0.16) - 0.08;
    _isChecking = false;

    if (type == 0) {
      final a = _random.nextInt(9) + 1;
      final b = _random.nextInt(9) + 1;
      _question = 'What is $a + $b?';
      _correctAnswer = '${a + b}';
    } else if (type == 1) {
      int a = _random.nextInt(9) + 1;
      int b = _random.nextInt(9) + 1;
      if (a < b) {
        final temp = a;
        a = b;
        b = temp;
      }
      _question = 'What is $a - $b?';
      _correctAnswer = '${a - b}';
    } else if (type == 2) {
      final a = _random.nextInt(20) + 1;
      final b = _random.nextInt(20) + 1;
      _question = 'Which number is larger: $a or $b?';
      _correctAnswer = '${a > b ? a : b}';
    } else {
      final numbers = List.generate(3, (_) => _random.nextInt(20) + 1);
      _question =
          'Enter the smallest number: ${numbers[0]}, ${numbers[1]}, ${numbers[2]}';
      final sorted = [...numbers]..sort();
      _correctAnswer = '${sorted.first}';
    }

    _answerController.clear();
    _isVerified = false;
    _message = '';

    if (notifyParent) {
      widget.onVerifiedChanged(false);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _resetCaptcha() {
    _answerController.clear();
    _isVerified = false;
    _message = '';
    _isChecking = false;
    widget.onVerifiedChanged(false);

    if (mounted) {
      setState(() {});
    }
  }

  void _autoCheckAnswer(String value) {
    final input = value.trim();

    if (input.isEmpty) {
      if (_isVerified || _message.isNotEmpty) {
        setState(() {
          _isVerified = false;
          _message = '';
          _isChecking = false;
        });
        widget.onVerifiedChanged(false);
      }
      return;
    }

    if (_isVerified || _isChecking) return;

    if (input.length >= _correctAnswer.length) {
      _verify();
    }
  }

  void _verify() {
    if (_isChecking) return;

    final input = _answerController.text.trim();
    if (input.isEmpty) return;

    _isChecking = true;

    if (input == _correctAnswer) {
      setState(() {
        _isVerified = true;
        _message = 'Verification successful';
        _isChecking = false;
      });
      widget.onVerifiedChanged(true);
    } else {
      setState(() {
        _isVerified = false;
        _message = 'Verification failed. Please try again.';
      });
      widget.onVerifiedChanged(false);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          _generateCaptcha();
        }
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF045F25);
    const darkGreen = Color(0xFF033D18);
    const pureWhite = Color(0xFFFFFFFF);
    const pureBlack = Color(0xFF000000);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isVerified
              ? Colors.green.withOpacity(0.45)
              : primaryGreen.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: primaryGreen, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: pureBlack.withOpacity(0.85),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _generateCaptcha(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  primaryGreen.withOpacity(0.05),
                  darkGreen.withOpacity(0.025),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: primaryGreen.withOpacity(0.12)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(child: _CaptchaNoiseLayer()),
                Transform.rotate(
                  angle: _rotationAngle,
                  child: Text(
                    _question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: pureBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (_isVerified) {
                setState(() {
                  _isVerified = false;
                  _message = '';
                });
                widget.onVerifiedChanged(false);
              }

              _autoCheckAnswer(value);
            },
            onSubmitted: (_) => _verify(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              isDense: true,
              filled: true,
              fillColor: pureWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen.withOpacity(0.14)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryGreen.withOpacity(0.14)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: primaryGreen, width: 1.2),
              ),
              /*  suffixIcon: IconButton(
                onPressed: _verify,
                icon: Icon(
                  _isVerified
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  color: _isVerified ? Colors.green : primaryGreen,
                  size: 20,
                ),
              ), */
            ),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _message,
              style: TextStyle(
                color: _isVerified ? Colors.green : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CaptchaNoiseLayer extends StatelessWidget {
  const _CaptchaNoiseLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CaptchaNoisePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CaptchaNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = Colors.black.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      final start = Offset(
        random.nextDouble() * size.width * 0.2,
        random.nextDouble() * size.height,
      );
      final end = Offset(
        size.width - random.nextDouble() * size.width * 0.2,
        random.nextDouble() * size.height,
      );
      canvas.drawLine(start, end, linePaint);
    }

    for (int i = 0; i < 14; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
