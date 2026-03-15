import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
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

  // Password tab
  final _pwdPhoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _pwdObscure = true;
  bool _pwdLoading = false;

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
        MaterialPageRoute(builder: widget.onLoginSuccess!),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _sendOtp() async {
    final phone = _otpPhoneCtrl.text.trim();
    if (phone.length < 10) {
      _showSnack('Please enter a valid 10-digit phone number');
      return;
    }
    setState(() => _otpLoading = true);
    final otp = await AuthService.sendOtp(phone);
    setState(() {
      _otpSent = otp != null;
      _otpLoading = false;
    });
    if (otp != null) {
      _showSnack('OTP sent! (Demo OTP: $otp)', duration: 6);
    } else {
      _showSnack('Could not send OTP. Is the server running?');
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _otpPhoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    if (otp.length != 4) {
      _showSnack('Please enter the 4-digit OTP');
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
        title: const Text(
          'Login',
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
          tabs: const [
            Tab(text: 'OTP Login'),
            Tab(text: 'Password'),
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
            label: 'Phone Number',
            hint: '10-digit mobile number',
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
              label: 'Get OTP',
              loading: _otpLoading,
              onTap: _sendOtp,
            )
          else ...[
            _inputField(
              controller: _otpCtrl,
              label: 'Enter OTP',
              hint: '4-digit OTP',
              icon: Icons.lock_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _otpSent = false;
                _otpCtrl.clear();
              }),
              child: const Text('Change Number / Resend OTP'),
            ),
            const SizedBox(height: 8),
            _primaryButton(
              label: 'Verify & Login',
              loading: _otpLoading,
              onTap: () => _verifyOtp(),
            ),
          ],
          const SizedBox(height: 32),
          _registerLink(),
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
            label: 'Phone Number',
            hint: '10-digit mobile number',
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
            label: 'Password',
            hint: 'Enter your password',
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
            label: 'Login',
            loading: _pwdLoading,
            onTap: _loginWithPassword,
          ),
          const SizedBox(height: 32),
          _registerLink(),
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
          color: AppColors.primaryMedium.withValues(alpha: 0.1),
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
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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

  Widget _registerLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('New here?',
            style: TextStyle(color: AppColors.grey700, fontSize: 14)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Register',
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
