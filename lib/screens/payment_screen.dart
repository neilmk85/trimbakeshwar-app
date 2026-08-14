import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'orders_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/booking_form_data.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/pooja_service.dart';
import '../services/razorpay_web_service_stub.dart'
    if (dart.library.js) '../services/razorpay_web_service.dart';

String _shortOrderId(DateTime now) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = math.Random(now.millisecondsSinceEpoch);
  final suffix = List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  return 'TP-$suffix';
}

class PaymentScreen extends StatefulWidget {
  final BookingFormData data;

  const PaymentScreen({super.key, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  late final Razorpay _razorpay;
  bool _processing = false;
  bool _razorpayOpened = false;

  BookingFormData get _data => widget.data;
  Color get _color => _data.primaryColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Razorpay sometimes doesn't fire EVENT_PAYMENT_ERROR when user dismisses
    // the sheet by pressing back. Reset spinner when app resumes in that case.
    if (state == AppLifecycleState.resumed && _razorpayOpened && _processing) {
      if (mounted) setState(() { _processing = false; _razorpayOpened = false; });
    }
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    if (str.length <= 5) return '₹${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    return '₹${str.substring(0, str.length - 5)},${str.substring(str.length - 5, str.length - 3)},${str.substring(str.length - 3)}';
  }

  String _colorHex(Color c) =>
      '#${c.r.round().toRadixString(16).padLeft(2, '0')}'
      '${c.g.round().toRadixString(16).padLeft(2, '0')}'
      '${c.b.round().toRadixString(16).padLeft(2, '0')}';

  Future<void> _startPayment() async {
    PoojaService.load(force: true, silent: true);
    setState(() => _processing = true);

    try {
      final user = AuthService.currentUser!;
      final now = DateTime.now();
      final baseOrderId = _shortOrderId(now);

      // Step 1 — create Razorpay order on server
      final result = await ApiService.createRazorpayOrder(_data.grandTotal, baseOrderId);
      if (result.data == null) {
        if (mounted) {
          setState(() => _processing = false);
          _showErrorDialog('Payment Failed', result.error ?? 'Could not initiate payment. Please try again.');
        }
        return;
      }

      final orderData = result.data!;
      _pendingOrderId = baseOrderId;
      _pendingRazorpayOrderId = orderData['razorpayOrderId'] as String;
      _pendingBookings = _buildBookingPayloads(baseOrderId, now, user.phone);

      if (kIsWeb) {
        // ── Web: use JS SDK ───────────────────────────────────────────────────
        if (mounted) setState(() => _processing = false);
        final webResult = await RazorpayWebService.open(
          key: orderData['keyId'] as String,
          amount: (orderData['amount'] as num).toInt(),
          orderId: _pendingRazorpayOrderId,
          currency: orderData['currency'] as String? ?? 'INR',
          name: AppStrings.gurujiName,
          description: _data.entries.map((e) => e.poojaName.isNotEmpty ? e.poojaName : e.selectedRoomName ?? 'Room').join(', '),
          prefillContact: user.phone,
          prefillEmail: user.email.isNotEmpty ? user.email : '',
          prefillName: user.fullName,
          themeColor: '#B71C1C',
        );

        if (!mounted) return;
        if (webResult.success) {
          await _onPaymentSuccess(
            paymentId: webResult.paymentId,
            razorpayOrderId: webResult.orderId,
            signature: webResult.signature,
          );
        } else if (webResult.errorCode == 'dismissed') {
          // User closed the modal — no error dialog needed
        } else {
          _showErrorDialog(
            'Payment Failed (${webResult.errorCode})',
            webResult.errorMessage ?? 'Payment could not be completed.',
          );
        }
      } else {
        // ── Mobile: use razorpay_flutter plugin ───────────────────────────────
        final options = {
          'key': orderData['keyId'] as String,
          'amount': (orderData['amount'] as num).toInt(),
          'order_id': _pendingRazorpayOrderId,
          'currency': orderData['currency'] as String? ?? 'INR',
          'name': AppStrings.gurujiName,
          'description': _data.entries.map((e) => e.poojaName).join(', '),
          'prefill': {
            'contact': user.phone,
            'email': user.email.isNotEmpty ? user.email : 'devotee@trimbakeshwar.com',
            'name': user.fullName,
          },
          'theme': {'color': '#0D47A1'},
          'config': {
            'display': {
              'blocks': {
                'utib': {'name': 'Pay via UPI', 'instruments': [{'method': 'upi'}]},
                'other': {'name': 'Other Payment Methods', 'instruments': [
                  {'method': 'card'},
                  {'method': 'netbanking'},
                  {'method': 'wallet'},
                  {'method': 'emi'},
                ]},
              },
              'sequence': ['block.utib', 'block.other'],
              'preferences': {'show_default_blocks': true},
            },
          },
        };
        _razorpayOpened = true;
        _razorpay.open(options);
        if (mounted) setState(() => _processing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        _showErrorDialog('Payment Error', e.toString());
      }
    }
  }

  Future<void> _onPaymentSuccess({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  }) async {
    // Show toast immediately — verify in background so there's no extra loading screen
    _updateLocalOrders();
    if (mounted) _showSuccessDialog();
    ApiService.verifyAndCreateBookings(
      razorpayOrderId: razorpayOrderId,
      paymentId: paymentId,
      signature: signature,
      bookings: _pendingBookings,
    ).then((verified) {
      if (!verified) {
        debugPrint('Payment verified but booking save failed. PaymentID: $paymentId');
      }
    });
  }

  void _updateLocalOrders() {
    final now = DateTime.now();
    for (int i = 0; i < _data.entries.length; i++) {
      final entry = _data.entries[i];
      final orderId = _data.entries.length > 1 ? '${_pendingOrderId}_${i + 1}' : _pendingOrderId;
      OrderService.ordersNotifier.value = [
        OrderModel(
          orderId: orderId,
          bookingType: entry.bookingType,
          poojaName: entry.poojaName,
          poojaDate: entry.poojaDate,
          checkInDate: entry.checkInDate,
          gotra: entry.gotra,
          numberOfPeople: entry.numberOfGuests,
          poojaRatePerPerson: entry.poojaAmount,
          isPrivatePooja: entry.isPrivatePooja,
          totalAmount: entry.totalAmount,
          numberOfRooms: entry.numberOfRooms,
          numberOfNights: entry.numberOfNights,
          stayRatePerRoom: entry.stayRatePerRoom,
          selectedRoomId: entry.selectedRoomId,
          selectedRoomName: entry.selectedRoomName,
          bookedOn: now,
          poojaColor: entry.poojaColor,
          bookedForName: _data.forMyself ? null : _data.bookedForName,
          bookedForPhone: _data.forMyself ? null : _data.bookedForPhone,
          bookedForEmail: _data.forMyself ? null : _data.bookedForEmail,
          bookedForCity: _data.forMyself ? null : _data.bookedForCity,
          bookedForZipCode: _data.forMyself ? null : _data.bookedForZipCode,
          bookedForCountry: _data.forMyself ? null : _data.bookedForCountry,
        ),
        ...OrderService.ordersNotifier.value,
      ];
    }
  }

  // Stored for use in callbacks
  String _pendingOrderId = '';
  String _pendingRazorpayOrderId = '';
  List<Map<String, dynamic>> _pendingBookings = [];

  List<Map<String, dynamic>> _buildBookingPayloads(String baseOrderId, DateTime now, String userPhone) {
    return List.generate(_data.entries.length, (i) {
      final entry = _data.entries[i];
      final orderId = _data.entries.length > 1 ? '${baseOrderId}_${i + 1}' : baseOrderId;
      final isRoomOnly = entry.bookingType == 'room_only';
      return {
        'orderId': orderId,
        'bookingType': entry.bookingType,
        if (!isRoomOnly) 'poojaName': entry.poojaName,
        if (!isRoomOnly && entry.poojaDate != null)
          'poojaDate': '${entry.poojaDate!.year}-${entry.poojaDate!.month.toString().padLeft(2, '0')}-${entry.poojaDate!.day.toString().padLeft(2, '0')}',
        if (entry.checkInDate != null)
          'checkInDate': '${entry.checkInDate!.year}-${entry.checkInDate!.month.toString().padLeft(2, '0')}-${entry.checkInDate!.day.toString().padLeft(2, '0')}',
        if (entry.selectedRoomId != null) 'roomId': entry.selectedRoomId,
        if (entry.selectedRoomName != null) 'roomName': entry.selectedRoomName,
        'gotra': entry.gotra,
        'totalAmount': entry.totalAmount,
        'numberOfPeople': entry.numberOfGuests,
        'isPrivatePooja': entry.isPrivatePooja,
        'poojaRatePerPerson': entry.poojaAmount,
        'numberOfRooms': entry.numberOfRooms,
        'numberOfNights': entry.numberOfNights,
        'stayRatePerRoom': entry.stayRatePerRoom,
        'poojaColorHex': _colorHex(entry.poojaColor),
        'bookedOn': now.toIso8601String(),
        'userPhone': userPhone,
        if (!_data.forMyself && _data.bookedForName != null) 'bookedForName': _data.bookedForName,
        if (!_data.forMyself && _data.bookedForPhone != null) 'bookedForPhone': _data.bookedForPhone,
        if (!_data.forMyself && _data.bookedForEmail != null) 'bookedForEmail': _data.bookedForEmail,
        if (!_data.forMyself && _data.bookedForCity != null) 'bookedForCity': _data.bookedForCity,
        if (!_data.forMyself && _data.bookedForZipCode != null) 'bookedForZipCode': _data.bookedForZipCode,
        if (!_data.forMyself) 'bookedForCountry': _data.bookedForCountry,
      };
    });
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _razorpayOpened = false;
    await _onPaymentSuccess(
      paymentId: response.paymentId ?? '',
      razorpayOrderId: response.orderId ?? _pendingRazorpayOrderId,
      signature: response.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _razorpayOpened = false;
    setState(() => _processing = false);
    _showErrorDialog(
      'Payment Error (code ${response.code})',
      response.message ?? 'Payment failed. Please try again.',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _razorpayOpened = false;
    setState(() => _processing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16)),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    HapticFeedback.heavyImpact();

    final poojaName = _data.entries.length == 1
        ? _data.entries.first.poojaName
        : _data.entries.map((e) => e.poojaName).join(', ');
    final date = _data.entries.first.poojaDate != null
        ? _formatDate(_data.entries.first.poojaDate!)
        : _data.entries.first.checkInDate != null
            ? _formatDate(_data.entries.first.checkInDate!)
            : '';
    final total = _formatAmount(_data.grandTotal);

    bool dismissed = false;
    OverlayEntry? entry;

    void goToOrders() {
      if (dismissed) return;
      dismissed = true;
      entry?.remove();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OrdersScreen(openDetailForOrderId: _pendingOrderId, backToPoojas: true)),
        (_) => false,
      );
    }

    entry = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => goToOrders(),
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: goToOrders,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _PaymentSuccessToast(
                      poojaName: poojaName,
                      date: date,
                      total: total,
                      onDismiss: goToOrders,
                      onViewDetails: goToOrders,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBookingSummary(),
                const SizedBox(height: 16),
                _buildPaymentInfo(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: ElevatedButton(
                onPressed: _processing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Pay Now  ${_formatAmount(_data.grandTotal)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.receipt_long_outlined, 'Booking Summary'),
          const SizedBox(height: 14),
          ..._data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_data.entries.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(entry.poojaName,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: entry.poojaColor)),
                      ),
                    _summaryRow(Icons.auto_awesome_outlined, 'Pooja', entry.poojaName),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.calendar_today_outlined, 'Date', entry.poojaDate != null ? _formatDate(entry.poojaDate!) : entry.checkInDate != null ? _formatDate(entry.checkInDate!) : '—'),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.family_restroom_outlined, 'Gotra', entry.gotra),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.currency_rupee_outlined, 'Pooja Amount', _formatAmount(entry.poojaAmount)),
                    if (entry.numberOfNights > 0) ...[
                      const SizedBox(height: 6),
                      _summaryRow(Icons.hotel_outlined, 'Stay',
                          '${entry.numberOfRooms} room(s) × ${entry.numberOfNights} night(s)'),
                      const SizedBox(height: 6),
                      _summaryRow(Icons.currency_rupee_outlined, 'Stay Amount', _formatAmount(entry.stayAmount)),
                    ],
                    if (_data.entries.last != entry) Divider(color: Colors.grey.shade200, height: 16),
                  ],
                ),
              )),
          ...[
            Divider(color: Colors.grey.shade200, height: 16),
            _summaryRow(
              Icons.person_outline,
              'Booked For',
              _data.forMyself
                  ? (AuthService.currentUser?.fullName.isNotEmpty == true
                      ? AuthService.currentUser!.fullName
                      : 'Self')
                  : (_data.bookedForName ?? 'Self'),
            ),
            if (!_data.forMyself && _data.bookedForPhone != null) ...[
              const SizedBox(height: 6),
              _summaryRow(Icons.phone_outlined, 'Contact', _data.bookedForPhone!),
            ],
          ],
          Divider(color: Colors.grey.shade200, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(_formatAmount(_data.grandTotal),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.payment_outlined, 'Secure Payment'),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Powered by Razorpay. Pay securely via UPI, Cards, Net Banking, or Wallets.',
                  style: TextStyle(fontSize: 13, color: AppColors.grey700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _paymentChip(Icons.account_balance_outlined, 'UPI'),
              _paymentChip(Icons.credit_card_outlined, 'Cards'),
              _paymentChip(Icons.account_balance, 'Net Banking'),
              _paymentChip(Icons.wallet_outlined, 'Wallets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey700),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey700)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _color, size: 18),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _color)),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.grey700, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _PaymentSuccessToast extends StatefulWidget {
  final String poojaName;
  final String date;
  final String total;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const _PaymentSuccessToast({
    required this.poojaName,
    required this.date,
    required this.total,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  State<_PaymentSuccessToast> createState() => _PaymentSuccessToastState();
}

class _PaymentSuccessToastState extends State<_PaymentSuccessToast>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final AnimationController _bellCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _bellAnim;
  final _audioPlayer = AudioPlayer();

  static const _saffron = Color(0xFFFF8F00);
  static const _saffronDark = Color(0xFFBF360C);

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bellCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);
    _bellAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.28), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.28, end: -0.28), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.28, end: 0.18), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.18, end: -0.10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.10, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    _slideCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), _ring);
    Future.delayed(const Duration(milliseconds: 1800), _ring);
  }

  void _ring() {
    if (!mounted) return;
    _bellCtrl
      ..reset()
      ..forward();
    HapticFeedback.mediumImpact();
    _audioPlayer.play(AssetSource('sounds/temple_bell.wav'));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _bellCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_saffron, _saffronDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _saffronDark.withValues(alpha: 0.55),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -10,
            top: -22,
            child: Text(
              'ॐ',
              style: TextStyle(
                fontSize: 118,
                color: Colors.white.withValues(alpha: 0.07),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bellAnim,
                      builder: (_, child) => Transform.rotate(
                        angle: _bellAnim.value,
                        alignment: Alignment.topCenter,
                        child: child,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Booking Confirmed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(height: 10),
                _row(Icons.auto_awesome_outlined, widget.poojaName),
                if (widget.date.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _row(Icons.calendar_today_outlined, widget.date),
                ],
                const SizedBox(height: 5),
                _row(Icons.currency_rupee_outlined, widget.total, bold: true),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'ॐ नमः शिवाय',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onViewDetails,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'View Booking Details',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
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

  Widget _row(IconData icon, String text, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
