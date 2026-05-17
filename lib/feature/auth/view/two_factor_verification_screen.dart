import 'package:afriendorse/athlete/feature/auth/widgets/auth_pattern_background.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final String sessionId;
  final String email;
  final String? redirectUrl;

  const TwoFactorVerificationScreen({
    super.key,
    required this.sessionId,
    required this.email,
    this.redirectUrl,
  });

  @override
  State<TwoFactorVerificationScreen> createState() =>
      _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState
    extends State<TwoFactorVerificationScreen>
    with SingleTickerProviderStateMixin {
  // ── OTP fields ─────────────────────────────────────────────────────────────
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _kGreen = Color(0xFF045F25);
  static const Color _kDarkGreen = Color(0xFF033D18);

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all 6 digits are filled
    if (_fullCode.length == 6) {
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Mask email: show first 2 chars + *** + domain
    final parts = widget.email.split('@');
    final maskedEmail = parts.length == 2
        ? '${parts[0].substring(0, parts[0].length.clamp(0, 2))}***@${parts[1]}'
        : widget.email;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────────────
          const Positioned.fill(child: _TwoFaBackground()),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _kGreen.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _kGreen,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GetBuilder<AuthController>(
                          builder: (authController) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),

                                // ── Shield icon badge ──────────────────────
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_kGreen, _kDarkGreen],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _kGreen.withOpacity(0.30),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.shield_outlined,
                                      color: Colors.white,
                                      size: 44,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // ── Heading ────────────────────────────────
                                const Text(
                                  'Two-Factor\nVerification',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.6,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ── Subtitle ───────────────────────────────
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF888888),
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'We sent a 6-digit code to\n',
                                      ),
                                      TextSpan(
                                        text: maskedEmail,
                                        style: const TextStyle(
                                          color: _kGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // ── OTP boxes ─────────────────────────────
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (i) {
                                    return _OtpBox(
                                      controller: _controllers[i],
                                      focusNode: _focusNodes[i],
                                      onChanged: (v) => _onDigitEntered(i, v),
                                      onBackspace: () => _onBackspace(i),
                                    );
                                  }),
                                ),

                                const SizedBox(height: 36),

                                // ── Verify button ──────────────────────────
                                _VerifyButton(
                                  isReady: _fullCode.length == 6,
                                  isLoading: authController.isLoading ?? false,
                                  onPressed: _fullCode.length == 6
                                      ? () async {
                                          await authController
                                              .verifyFirestoreTwoFactorCode(
                                                sessionId: widget.sessionId,
                                                code: _fullCode,
                                                email: widget.email,
                                              );
                                        }
                                      : null,
                                ),

                                const SizedBox(height: 28),

                                // ── Timer / Resend ─────────────────────────
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _seconds > 0
                                      ? _TimerBadge(seconds: _seconds)
                                      : _ResendButton(
                                          onTap: () async {
                                            await authController
                                                .resendFirestoreTwoFactorCode(
                                                  sessionId: widget.sessionId,
                                                  email: widget.email,
                                                );
                                            _startTimer();
                                          },
                                        ),
                                ),

                                const SizedBox(height: 40),

                                // ── Security note ──────────────────────────
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _kGreen.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _kGreen.withOpacity(0.12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: _kGreen.withOpacity(0.7),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'This code expires in 10 minutes. '
                                          'Never share it with anyone.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF555555),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP single box
// ─────────────────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  static const Color _kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: focusNode.hasFocus
                ? _kGreen.withOpacity(0.06)
                : Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: controller.text.isNotEmpty
                    ? _kGreen
                    : Colors.grey.shade200,
                width: controller.text.isNotEmpty ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kGreen, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verify button
// ─────────────────────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  final bool isReady;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _VerifyButton({
    required this.isReady,
    required this.isLoading,
    required this.onPressed,
  });

  static const Color _kGreen = Color(0xFF045F25);
  static const Color _kDarkGreen = Color(0xFF033D18);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isReady
            ? const LinearGradient(
                colors: [_kGreen, _kDarkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isReady ? null : Colors.grey.shade200,
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: _kGreen.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: isReady ? Colors.white : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verify & Continue',
                        style: TextStyle(
                          color: isReady ? Colors.white : Colors.grey.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer badge
// ─────────────────────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int seconds;
  const _TimerBadge({required this.seconds});

  static const Color _kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    // Progress from 1.0 → 0.0 as seconds count down from 60
    final progress = seconds / 60.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              seconds > 20 ? _kGreen : Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Resend code in ${seconds}s',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resend button
// ─────────────────────────────────────────────────────────────────────────────

class _ResendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ResendButton({required this.onTap});

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  bool _isSending = false;

  static const Color _kGreen = Color(0xFF045F25);

  Future<void> _handleTap() async {
    if (_isSending) return; // ← guard against double-tap

    setState(() => _isSending = true);

    try {
      widget.onTap();
    } finally {
      // Keep disabled for 3 seconds even if onTap returns instantly
      // so the user sees clear feedback before the timer takes over
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSending ? null : _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _isSending
              ? _kGreen.withOpacity(0.04)
              : _kGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _isSending
                ? _kGreen.withOpacity(0.10)
                : _kGreen.withOpacity(0.20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinner while sending, icon when idle
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSending
                  ? SizedBox(
                      key: const ValueKey('spinner'),
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _kGreen.withOpacity(0.5),
                        ),
                      ),
                    )
                  : const Icon(
                      key: ValueKey('icon'),
                      Icons.refresh_rounded,
                      color: _kGreen,
                      size: 16,
                    ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _isSending ? _kGreen.withOpacity(0.40) : _kGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              child: Text(_isSending ? 'Sending...' : 'Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
//6a7e097bec51e0b9320ad5a64f81a12e
//mailtrap
// ─────────────────────────────────────────────────────────────────────────────
// Background (reuses the same sports pattern from auth screens)
// ─────────────────────────────────────────────────────────────────────────────

class _TwoFaBackground extends StatelessWidget {
  const _TwoFaBackground();

  @override
  Widget build(BuildContext context) {
    return const AuthFaPatternBackground(formMode: true);
  }
}
