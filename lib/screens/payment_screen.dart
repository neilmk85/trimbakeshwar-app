import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/booking_form_data.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  final BookingFormData data;

  const PaymentScreen({super.key, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _PaymentMethod { upiApp, upiId }

enum _UpiApp { gpay, phonepe, paytm, bhim }

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _method = _PaymentMethod.upiApp;
  _UpiApp _selectedApp = _UpiApp.gpay;
  final _upiIdCtrl = TextEditingController();
  bool _processing = false;

  BookingFormData get _data => widget.data;
  Color get _color => _data.primaryColor;

  @override
  void dispose() {
    _upiIdCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    if (str.length <= 5) {
      return '₹${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return '₹${str.substring(0, str.length - 5)},${str.substring(str.length - 5, str.length - 3)},${str.substring(str.length - 3)}';
  }

  Future<void> _pay() async {
    if (_method == _PaymentMethod.upiId) {
      final id = _upiIdCtrl.text.trim();
      if (id.isEmpty || !id.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid UPI ID (e.g. name@upi)'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }
    setState(() => _processing = true);

    final userPhone = AuthService.currentUser!.phone;
    final now = DateTime.now();
    final baseOrderId = 'ORD${now.millisecondsSinceEpoch}';

    bool allSaved = true;
    for (int i = 0; i < _data.entries.length; i++) {
      final entry = _data.entries[i];
      final orderId =
          _data.entries.length > 1 ? '${baseOrderId}_${i + 1}' : baseOrderId;

      final saved = await OrderService.addOrder(
        OrderModel(
          orderId: orderId,
          poojaName: entry.poojaName,
          poojaDate: entry.poojaDate,
          numberOfPeople: entry.numberOfPeople,
          gotra: entry.gotra,
          totalAmount: entry.totalAmount,
          bookedOn: now,
          poojaColor: entry.poojaColor,
          bookedForName: _data.forMyself ? null : _data.bookedForName,
          bookedForPhone: _data.forMyself ? null : _data.bookedForPhone,
          bookedForEmail: _data.forMyself ? null : _data.bookedForEmail,
          bookedForCity: _data.forMyself ? null : _data.bookedForCity,
          bookedForZipCode: _data.forMyself ? null : _data.bookedForZipCode,
          bookedForCountry: _data.forMyself ? null : _data.bookedForCountry,
        ),
        userPhone,
      );
      if (!saved) allSaved = false;
    }

    setState(() => _processing = false);
    if (!mounted) return;

    if (allSaved) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Booking could not be saved. Please check your connection and try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF2E7D32), size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _data.entries.length == 1
                  ? 'Your ${_data.entries.first.poojaName} has been booked for ${_formatDate(_data.entries.first.poojaDate)}.'
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
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
                _buildPaymentOptions(),
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
                onPressed: _processing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Pay Now  ${_formatAmount(_data.grandTotal)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
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
                        child: Text(
                          entry.poojaName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: entry.poojaColor),
                        ),
                      ),
                    _summaryRow(Icons.auto_awesome_outlined, 'Pooja',
                        entry.poojaName),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.calendar_today_outlined, 'Date',
                        _formatDate(entry.poojaDate)),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.people_outline, 'People',
                        '${entry.numberOfPeople}'),
                    const SizedBox(height: 6),
                    _summaryRow(
                        Icons.family_restroom_outlined, 'Gotra', entry.gotra),
                    const SizedBox(height: 6),
                    _summaryRow(Icons.currency_rupee_outlined, 'Amount',
                        _formatAmount(entry.totalAmount)),
                    if (_data.entries.last != entry)
                      Divider(color: Colors.grey.shade200, height: 16),
                  ],
                ),
              )),
          if (!_data.forMyself && _data.bookedForName != null) ...[
            Divider(color: Colors.grey.shade200, height: 16),
            _summaryRow(
                Icons.person_outline, 'Booked For', _data.bookedForName!),
            if (_data.bookedForPhone != null) ...[
              const SizedBox(height: 6),
              _summaryRow(Icons.phone_outlined, 'Contact',
                  _data.bookedForPhone!),
            ],
          ],
          Divider(color: Colors.grey.shade200, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                _formatAmount(_data.grandTotal),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.payment_outlined, 'Choose Payment Method'),
          const SizedBox(height: 16),
          _methodTile(
            value: _PaymentMethod.upiApp,
            title: 'Pay with UPI App',
            icon: Icons.smartphone_outlined,
            child: _method == _PaymentMethod.upiApp ? _buildUpiApps() : null,
          ),
          const SizedBox(height: 12),
          _methodTile(
            value: _PaymentMethod.upiId,
            title: 'Enter UPI ID',
            icon: Icons.alternate_email,
            child:
                _method == _PaymentMethod.upiId ? _buildUpiIdField() : null,
          ),
        ],
      ),
    );
  }

  Widget _methodTile({
    required _PaymentMethod value,
    required String title,
    required IconData icon,
    Widget? child,
  }) {
    final selected = _method == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _color : Colors.grey.shade300,
          width: selected ? 1.5 : 1,
        ),
        color:
            selected ? _color.withValues(alpha: 0.04) : Colors.transparent,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _method = value),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Radio<_PaymentMethod>(
                    value: value,
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v!),
                    activeColor: _color,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Icon(icon,
                      size: 20,
                      color: selected ? _color : AppColors.grey700),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? _color : AppColors.grey800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildUpiApps() {
    return Column(
      children: [
        const SizedBox(height: 4),
        ..._UpiApp.values.map((app) => _upiAppTile(app)),
      ],
    );
  }

  Widget _upiAppTile(_UpiApp app) {
    final selected = _selectedApp == app;
    return InkWell(
      onTap: () => setState(() => _selectedApp = app),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<_UpiApp>(
              value: app,
              groupValue: _selectedApp,
              onChanged: (v) => setState(() => _selectedApp = v!),
              activeColor: _color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            _UpiLogo(app: app),
            const SizedBox(width: 12),
            Text(
              _appName(app),
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiIdField() {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: _upiIdCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'yourname@upi',
            prefixIcon: const Icon(Icons.alternate_email,
                color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  String _appName(_UpiApp app) {
    switch (app) {
      case _UpiApp.gpay:
        return 'Google Pay';
      case _UpiApp.phonepe:
        return 'PhonePe';
      case _UpiApp.paytm:
        return 'Paytm';
      case _UpiApp.bhim:
        return 'BHIM UPI';
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
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
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _color, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _color,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: AppColors.grey700, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── UPI App Logo Widget ────────────────────────────────────────────────────────

class _UpiLogo extends StatelessWidget {
  final _UpiApp app;
  const _UpiLogo({required this.app});

  @override
  Widget build(BuildContext context) {
    switch (app) {
      case _UpiApp.gpay:
        return _logoContainer(
          color: Colors.white,
          border: Colors.grey.shade300,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('G',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4))),
              Text('P',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34A853))),
              Text('a',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA4335))),
              Text('y',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFBBC05))),
            ],
          ),
        );
      case _UpiApp.phonepe:
        return _logoContainer(
          color: const Color(0xFF5F259F),
          child: const Text(
            'Pe',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        );
      case _UpiApp.paytm:
        return _logoContainer(
          color: const Color(0xFF00BAF2),
          child: const Text(
            'Paytm',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        );
      case _UpiApp.bhim:
        return _logoContainer(
          color: const Color(0xFF0E519B),
          child: const Text(
            'BHIM',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        );
    }
  }

  Widget _logoContainer({
    required Color color,
    required Widget child,
    Color? border,
  }) {
    return Container(
      width: 46,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: border != null ? Border.all(color: border) : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
