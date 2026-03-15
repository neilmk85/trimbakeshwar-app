import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/countries.dart';
import '../models/booking_form_data.dart';
import '../services/pooja_service.dart';
import 'payment_screen.dart';

// ── Internal cart item ────────────────────────────────────────────────────────

class _CartItem {
  String poojaName;
  DateTime? date;
  int numberOfPeople;
  final TextEditingController gotraCtrl;

  _CartItem({
    required this.poojaName,
    this.date,
    this.numberOfPeople = 1,
  }) : gotraCtrl = TextEditingController();

  void dispose() => gotraCtrl.dispose();

  int costPerPerson(List poojas) =>
      poojas.where((p) => p.name == poojaName).firstOrNull?.pricePerPerson ?? 0;

  int totalAmount(List poojas) => costPerPerson(poojas) * numberOfPeople;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  final String selectedPooja;

  const BookingScreen({super.key, required this.selectedPooja});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Cart
  late List<_CartItem> _items;

  // Booking-for
  bool _forMyself = true;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _country = 'India';

  @override
  void initState() {
    super.initState();
    _items = [_CartItem(poojaName: widget.selectedPooja)];
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List get _poojas => PoojaService.poojas.value;

  int get _grandTotal =>
      _items.fold(0, (s, item) => s + item.totalAmount(_poojas));

  Color get _primaryColor =>
      _poojas
          .where((p) => p.name == _items.first.poojaName)
          .firstOrNull
          ?.color ??
      AppColors.primary;

  String _formatAmount(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    if (str.length <= 5) {
      return '₹${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return '₹${str.substring(0, str.length - 5)},${str.substring(str.length - 5, str.length - 3)},${str.substring(str.length - 3)}';
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

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _items[index].date = picked);
  }

  void _addPooja() {
    setState(() {
      _items.add(_CartItem(poojaName: _poojas.first.name));
    });
  }

  void _removePooja(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _proceed() {
    // Validate all cart items
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.gotraCtrl.text.trim().isEmpty) {
        _snack('Please enter Gotra for Pooja ${i + 1}');
        return;
      }
      if (item.date == null) {
        _snack('Please select a date for ${item.poojaName}');
        return;
      }
    }

    // Validate "someone else" fields
    if (!_forMyself) {
      if (_nameCtrl.text.trim().isEmpty) {
        _snack('Please enter the person\'s name');
        return;
      }
      if (_phoneCtrl.text.trim().isEmpty) {
        _snack('Please enter the person\'s mobile number');
        return;
      }
    }

    final entries = _items
        .map((item) => BookingEntry(
              poojaName: item.poojaName,
              poojaDate: item.date!,
              numberOfPeople: item.numberOfPeople,
              gotra: item.gotraCtrl.text.trim(),
              totalAmount: item.totalAmount(_poojas),
              poojaColor: _poojas
                      .where((p) => p.name == item.poojaName)
                      .firstOrNull
                      ?.color ??
                  AppColors.primary,
            ))
        .toList();

    final formData = BookingFormData(
      entries: entries,
      forMyself: _forMyself,
      bookedForName: _forMyself ? null : _nameCtrl.text.trim(),
      bookedForPhone: _forMyself ? null : _phoneCtrl.text.trim(),
      bookedForEmail: _forMyself
          ? null
          : (_emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim()),
      bookedForCity: _forMyself
          ? null
          : (_cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim()),
      bookedForZipCode: _forMyself
          ? null
          : (_zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim()),
      bookedForCountry: _forMyself ? 'India' : _country,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(data: formData)),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Book Pooja',
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
                // Booking For section
                _buildBookingForCard(),
                const SizedBox(height: 14),

                // Pooja items
                ...List.generate(_items.length, (i) => Column(
                  children: [
                    _buildPoojaCard(i),
                    const SizedBox(height: 14),
                  ],
                )),

                // Add another pooja button
                if (_poojas.length > 1)
                  OutlinedButton.icon(
                    onPressed: _addPooja,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Pooja'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                const SizedBox(height: 14),

                // Cost summary
                _buildCostSummary(),
              ],
            ),
          ),
          // Proceed button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  'Proceed to Payment  ${_formatAmount(_grandTotal)}',
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

  // ── Section: Booking For ─────────────────────────────────────────────────────

  Widget _buildBookingForCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.person_outline, 'Booking For'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _forToggle('Myself', true)),
              const SizedBox(width: 12),
              Expanded(child: _forToggle('Someone Else', false)),
            ],
          ),
          if (!_forMyself) ...[
            const SizedBox(height: 16),
            _textField(
              controller: _nameCtrl,
              hint: 'Full Name',
              icon: Icons.person_outline,
              caps: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            _textField(
              controller: _phoneCtrl,
              hint: 'Mobile Number',
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            _textField(
              controller: _emailCtrl,
              hint: 'Email (optional)',
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _textField(
              controller: _cityCtrl,
              hint: 'City (optional)',
              icon: Icons.location_city_outlined,
              caps: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            _textField(
              controller: _zipCtrl,
              hint: 'ZIP / PIN Code (optional)',
              icon: Icons.pin_drop_outlined,
              type: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _country,
              isExpanded: true,
              decoration: _inputDecoration('Country', Icons.flag_outlined),
              items: AppCountries.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _country = v);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _forToggle(String label, bool value) {
    final selected = _forMyself == value;
    return GestureDetector(
      onTap: () => setState(() => _forMyself = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  // ── Section: Individual Pooja Card ───────────────────────────────────────────

  Widget _buildPoojaCard(int index) {
    final item = _items[index];
    final color = _poojas
            .where((p) => p.name == item.poojaName)
            .firstOrNull
            ?.color ??
        AppColors.primary;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  Icons.auto_awesome_outlined,
                  _items.length > 1 ? 'Pooja ${index + 1}' : 'Pooja Details',
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  onPressed: () => _removePooja(index),
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.red.shade400,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Pooja dropdown
          DropdownButtonFormField<String>(
            value: item.poojaName,
            isExpanded: true,
            decoration:
                _inputDecoration('Select Pooja', Icons.auto_awesome_outlined),
            items: _poojas
                .map((p) => DropdownMenuItem<String>(
                      value: p.name,
                      child: Text(p.name),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => item.poojaName = v);
            },
          ),
          const SizedBox(height: 12),

          // Gotra
          TextFormField(
            controller: item.gotraCtrl,
            textCapitalization: TextCapitalization.words,
            decoration:
                _inputDecoration('Enter Gotra', Icons.family_restroom_outlined),
          ),
          const SizedBox(height: 12),

          // Date picker
          GestureDetector(
            onTap: () => _pickDate(index),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    item.date == null
                        ? 'Select Pooja Date'
                        : _formatDate(item.date!),
                    style: TextStyle(
                      fontSize: 15,
                      color: item.date == null
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: AppColors.grey500),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Number of people
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'People',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700),
              ),
              const Spacer(),
              IconButton(
                onPressed: item.numberOfPeople > 1
                    ? () => setState(() => item.numberOfPeople--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: item.numberOfPeople > 1
                    ? AppColors.primary
                    : AppColors.grey300,
                iconSize: 28,
                visualDensity: VisualDensity.compact,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${item.numberOfPeople}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: item.numberOfPeople < 20
                    ? () => setState(() => item.numberOfPeople++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: item.numberOfPeople < 20
                    ? AppColors.primary
                    : AppColors.grey300,
                iconSize: 28,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          // Per-item cost row
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${item.costPerPerson(_poojas)} × ${item.numberOfPeople}',
                  style: TextStyle(
                      fontSize: 13, color: color, fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatAmount(item.totalAmount(_poojas)),
                  style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section: Cost Summary ────────────────────────────────────────────────────

  Widget _buildCostSummary() {
    final color = _primaryColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Cost Summary',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.poojaName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.grey700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatAmount(item.totalAmount(_poojas)),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
          if (_items.length > 1) ...[
            Divider(color: color.withValues(alpha: 0.3), height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  _formatAmount(_grandTotal),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color),
                ),
              ],
            ),
          ] else ...[
            Divider(color: color.withValues(alpha: 0.3), height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  _formatAmount(_grandTotal),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Reusable widgets ─────────────────────────────────────────────────────────

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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      textCapitalization: caps,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(hint, icon),
    );
  }
}
