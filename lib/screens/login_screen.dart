import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../services/auth_service.dart';
import '../utils/app_route.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  /// If provided, called with a builder for the screen to push after login.
  final WidgetBuilder? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // OTP tab
  final _otpPhoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _otpLoading = false;
  bool _demoMode = false; // true when server is unreachable

  // Password tab
  final _pwdPhoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _pwdObscure = true;
  bool _pwdLoading = false;

  // SSO
  bool _ssoLoading = false;
  bool _appleLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _otpPhoneCtrl.dispose();
    _otpCtrl.dispose();
    _pwdPhoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _handleLoginSuccess() {
    if (widget.onLoginSuccess != null) {
      Navigator.pushReplacement(
        context,
        fadeSlideRoute(widget.onLoginSuccess!),
      );
    } else {
      Navigator.pop(context);
    }
  }

  static bool _isConnectionError(String error) {
    final e = error.toLowerCase();
    return e.contains('connect') || e.contains('reach') || e.contains('socket') || e.contains('timed out');
  }

  Future<void> _sendOtp() async {
    final phone = _otpPhoneCtrl.text.trim();
    if (phone.length < 10) {
      _showSnack('Please enter a valid 10-digit phone number');
      return;
    }
    setState(() => _otpLoading = true);
    final result = await AuthService.sendOtp(phone);
    if (!mounted) return;

    if (result.otp != null) {
      setState(() { _otpSent = true; _demoMode = false; _otpLoading = false; });
      _showSnack('OTP sent to your WhatsApp number', duration: 6);
    } else if (_isConnectionError(result.error ?? '')) {
      // Server unreachable — fall back to demo OTP
      setState(() { _otpSent = true; _demoMode = true; _otpLoading = false; });
      _showSnack('Server offline. Use demo OTP: 1234', duration: 8);
    } else {
      setState(() => _otpLoading = false);
      _showSnack(result.error ?? 'Could not send OTP.', duration: 6);
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _otpPhoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    if (otp.length != 4) {
      _showSnack('Please enter the 4-digit OTP');
      return;
    }

    if (_demoMode) {
      if (otp == '1234') {
        AuthService.loginAsGuest(phone);
        _handleLoginSuccess();
      } else {
        _showSnack('Incorrect OTP. Demo OTP is: 1234');
      }
      return;
    }

    setState(() => _otpLoading = true);
    final error = await AuthService.verifyOtpAndLogin(phone, otp);
    setState(() => _otpLoading = false);
    if (error == null) {
      _handleLoginSuccess();
    } else {
      _showSnack(error);
    }
  }

  Future<void> _loginWithPassword() async {
    final phone = _pwdPhoneCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    if (phone.isEmpty || pwd.isEmpty) {
      _showSnack('Please enter phone number and password');
      return;
    }
    setState(() => _pwdLoading = true);
    final error = await AuthService.loginWithPassword(phone, pwd);
    setState(() => _pwdLoading = false);
    if (error == null) {
      _handleLoginSuccess();
    } else {
      _showSnack(error);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _ssoLoading = true);
    final error = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _ssoLoading = false);
    if (error == null) {
      _handleLoginSuccess();
    } else {
      _showSnack(error);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _appleLoading = true);
    final error = await AuthService.signInWithApple();
    if (!mounted) return;
    setState(() => _appleLoading = false);
    if (error == null) {
      _handleLoginSuccess();
    } else {
      _showSnack(error);
    }
  }

  void _showSnack(String msg, {int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppL10n.s.loginTitle,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.appBarGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: [
            Tab(text: AppL10n.s.otpLogin),
            Tab(text: AppL10n.s.passwordTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOtpTab(),
          _buildPasswordTab(),
        ],
      ),
    );
  }

  Widget _buildOtpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _sectionIcon(),
          const SizedBox(height: 24),
          _inputField(
            controller: _otpPhoneCtrl,
            label: AppL10n.s.phoneNumberLabel,
            hint: AppL10n.s.phonePlaceholder,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            enabled: !_otpSent,
          ),
          const SizedBox(height: 16),
          if (!_otpSent)
            _primaryButton(
              label: AppL10n.s.getOtp,
              loading: _otpLoading,
              onTap: _sendOtp,
            )
          else ...[
            AutofillGroup(
              child: _inputField(
                controller: _otpCtrl,
                label: AppL10n.s.enterOtp,
                hint: AppL10n.s.otpPlaceholder,
                icon: Icons.lock_outlined,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _otpSent = false;
                _demoMode = false;
                _otpCtrl.clear();
              }),
              child: Text(AppL10n.s.changeResendOtp),
            ),
            const SizedBox(height: 8),
            _primaryButton(
              label: AppL10n.s.verifyLogin,
              loading: _otpLoading,
              onTap: () => _verifyOtp(),
            ),
          ],
          const SizedBox(height: 8),
          _registerLink(),
          _buildSsoSection(),
        ],
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _sectionIcon(),
          const SizedBox(height: 24),
          _inputField(
            controller: _pwdPhoneCtrl,
            label: AppL10n.s.phoneNumberLabel,
            hint: AppL10n.s.phonePlaceholder,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _pwdCtrl,
            label: AppL10n.s.passwordLabel,
            hint: AppL10n.s.enterPassword,
            icon: Icons.lock_outlined,
            obscureText: _pwdObscure,
            suffixIcon: IconButton(
              icon: Icon(
                  _pwdObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey500),
              onPressed: () => setState(() => _pwdObscure = !_pwdObscure),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label: AppL10n.s.loginTitle,
            loading: _pwdLoading,
            onTap: _loginWithPassword,
          ),
          const SizedBox(height: 8),
          _registerLink(),
          _buildSsoSection(),
        ],
      ),
    );
  }

  Widget _sectionIcon() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_outline_rounded,
            size: 36, color: AppColors.primary),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    List<String>? autofillHints,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSsoSection() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(AppL10n.s.orDivider,
                    style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          _ssoButton(
            loading: _ssoLoading,
            onTap: _signInWithGoogle,
            icon: const _GoogleIcon(),
            label: AppL10n.s.continueGoogle,
          ),
        ],
      ),
    );
  }

  Widget _ssoButton({
    required bool loading,
    required VoidCallback onTap,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }

  Widget _registerLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppL10n.s.newHere,
            style: TextStyle(color: AppColors.grey700, fontSize: 14)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            fadeSlideRoute((_) => const RegisterScreen()),
          ),
          child: Text(
            AppL10n.s.registerLabel,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final strokeW = size.width * 0.175;

    // Arc paints
    final blue   = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt;
    final red    = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt;
    final yellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt;
    final green  = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt;

    final arcRect = Rect.fromCircle(center: center, radius: r - strokeW / 2);

    // Red: top-right → top-left (315° → 225°) = -150° sweep
    canvas.drawArc(arcRect, -0.524, -2.618, false, red);
    // Yellow: bottom-left → left (225° → 180°)
    canvas.drawArc(arcRect, -0.524 - 2.618, -0.785, false, yellow);
    // Green: bottom-right → bottom-left
    canvas.drawArc(arcRect, 0, -0.524, false, green);
    // Blue: right → top-right (0° → -45°) + the horizontal bar
    canvas.drawArc(arcRect, -0.785, 1.309, false, blue);

    // Blue horizontal bar on right side
    final barPaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final barTop = center.dy - strokeW * 0.5;
    final barBottom = center.dy + strokeW * 0.5;
    canvas.drawRect(Rect.fromLTRB(center.dx, barTop, size.width, barBottom), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
