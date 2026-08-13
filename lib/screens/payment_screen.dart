import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
          'theme': {'color': '#B71C1C'},
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
    setState(() => _processing = true);
    final verified = await ApiService.verifyAndCreateBookings(
      razorpayOrderId: razorpayOrderId,
      paymentId: paymentId,
      signature: signature,
      bookings: _pendingBookings,
    );
    _updateLocalOrders();
    setState(() => _processing = false);
    if (!mounted) return;
    if (verified) {
      _showSuccessDialog();
    } else {
      _showError('Payment received but booking could not be saved. Please contact support with Payment ID: $paymentId');
    }
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
    final poojaNames = _data.entries.map((e) => e.poojaName).join(', ');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 42),
            ),
            const SizedBox(height: 16),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _data.entries.length == 1
                  ? 'Your booking has been confirmed for ${_data.entries.first.checkInDate != null ? _formatDate(_data.entries.first.checkInDate!) : _data.entries.first.poojaDate != null ? _formatDate(_data.entries.first.poojaDate!) : '—'}.'
                  : '$poojaNames have been booked successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey700, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
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
          if (!_data.forMyself && _data.bookedForName != null) ...[
            Divider(color: Colors.grey.shade200, height: 16),
            _summaryRow(Icons.person_outline, 'Booked For', _data.bookedForName!),
            if (_data.bookedForPhone != null) ...[
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
