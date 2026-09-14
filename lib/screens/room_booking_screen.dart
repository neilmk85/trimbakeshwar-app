import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/booking_form_data.dart';
import '../models/room_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

String _fmt2(int n) => n.toString().padLeft(2, '0');

String _formatDate(DateTime d) =>
    '${_fmt2(d.day)} ${_monthName(d.month)} ${d.year}';

String _monthName(int m) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][m];

String _isoDate(DateTime d) =>
    '${d.year}-${_fmt2(d.month)}-${_fmt2(d.day)}';

String _formatAmount(int amt) {
  final s = amt.toString();
  if (s.length <= 3) return '₹$s';
  if (s.length <= 5) return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  return '₹${s.substring(0, s.length - 5)},${s.substring(s.length - 5, s.length - 3)},${s.substring(s.length - 3)}';
}

class RoomBookingScreen extends StatefulWidget {
  final RoomModel room;
  const RoomBookingScreen({super.key, required this.room});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _rooms = 1;
  int _guests = 1;
  bool _forMyself = true;

  // Availability state
  bool _checkingAvailability = false;
  bool? _isAvailable;
  int _availableCount = 0;
  String _availabilityMessage = '';

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl  = TextEditingController();
  final _zipCtrl   = TextEditingController();
  String _country  = 'India';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  int get _nights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  int get _total => widget.room.pricePerNight * _rooms * (_nights > 0 ? _nights : 1);

  // ── Date range picker ────────────────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (_) => _DateRangePickerDialog(
        initialStart: _checkInDate ?? today,
        initialEnd: _checkOutDate,
        first: today,
        last: DateTime(now.year + 2),
      ),
    );
    if (result == null) return;
    DateTime? newCheckOut = _checkOutDate;
    if (result.end.isAfter(result.start)) {
      newCheckOut = result.end;
    } else {
      newCheckOut = result.start.add(const Duration(days: 1));
    }
    setState(() {
      _checkInDate = result.start;
      _checkOutDate = newCheckOut;
      _isAvailable = null;
      _availabilityMessage = '';
    });
    await _checkAvailability();
  }

  // ── Availability check ────────────────────────────────────────────────────────

  Future<void> _checkAvailability() async {
    if (_checkInDate == null || _checkOutDate == null) return;
    setState(() {
      _checkingAvailability = true;
      _isAvailable = null;
      _availabilityMessage = '';
    });
    try {
      final base = ApiService.baseUrl.replaceFirst('/api', '');
      final uri = Uri.parse(
          '$base/api/rooms/${widget.room.id}/availability'
          '?checkIn=${_isoDate(_checkInDate!)}&checkOut=${_isoDate(_checkOutDate!)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final body = jsonDecode(res.body);
      final data = body['data'] ?? body;
      setState(() {
        _isAvailable = data['available'] == true;
        _availableCount = (data['availableCount'] as num?)?.toInt() ?? 0;
        _availabilityMessage = data['message'] ?? '';
        _checkingAvailability = false;
        // Clamp rooms to available count
        if (_isAvailable == true && _rooms > _availableCount) {
          _rooms = _availableCount;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingAvailability = false;
        _availabilityMessage = 'Could not check availability. Please try again.';
        _isAvailable = null;
      });
    }
  }

  // ── Proceed ───────────────────────────────────────────────────────────────────

  void _proceed() {
    if (_checkInDate == null) { _snack('Please select a check-in date'); return; }
    if (_checkOutDate == null) { _snack('Please select a check-out date'); return; }
    if (_nights < 1) { _snack('Check-out must be after check-in'); return; }
    if (_isAvailable == false) { _snack('Room is not available for selected dates'); return; }
    if (!_forMyself) {
      if (_nameCtrl.text.trim().isEmpty) { _snack('Please enter the guest name'); return; }
      if (_phoneCtrl.text.trim().length < 10) { _snack('Please enter a valid phone number'); return; }
    }
    final user = AuthService.currentUser;
    if (user == null) { _snack('Please log in to proceed'); return; }

    final entry = BookingEntry(
      bookingType: 'room_only',
      poojaName: '',
      poojaDate: null,
      checkInDate: _checkInDate,
      gotra: '',
      poojaAmount: 0,
      poojaColor: const Color(0xFF1565C0),
      numberOfRooms: _rooms,
      numberOfNights: _nights,
      numberOfGuests: _guests,
      stayRatePerRoom: widget.room.pricePerNight,
      selectedRoomId: widget.room.id,
      selectedRoomName: widget.room.name,
    );

    final formData = BookingFormData(
      entries: [entry],
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
      bookedForCountry: _country,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentScreen(data: formData)),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Book Room'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _roomHeader(room),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Stay Details',
            icon: Icons.hotel_rounded,
            children: [
              _dateRangeTile(),
              if (_checkInDate != null && _checkOutDate != null) ...[
                const Divider(height: 1),
                _nightsSummaryTile(),
              ],
              const Divider(height: 1),
              _stepperTile(
                'Rooms',
                Icons.door_front_door_outlined,
                _rooms,
                1,
                (_isAvailable == true && _availableCount > 0)
                    ? _availableCount.clamp(1, room.count)
                    : room.count,
                onDec: () => setState(() => _rooms = (_rooms - 1).clamp(1, room.count)),
                onInc: () => setState(() => _rooms = (_rooms + 1).clamp(1,
                    (_isAvailable == true && _availableCount > 0)
                        ? _availableCount
                        : room.count)),
              ),
              const Divider(height: 1),
              _stepperTile(
                'Guests',
                Icons.people_outline_rounded,
                _guests,
                1,
                20,
                onDec: () => setState(() => _guests = (_guests - 1).clamp(1, 20)),
                onInc: () => setState(() => _guests = (_guests + 1).clamp(1, 20)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Availability banner
          _availabilityBanner(),

          const SizedBox(height: 16),
          _sectionCard(
            title: 'Booking For',
            icon: Icons.person_rounded,
            children: [
              _forMyselfToggle(),
              if (!_forMyself) ...[
                const Divider(height: 1),
                _field(_nameCtrl, 'Guest Name', Icons.person_outline),
                _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                    type: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ]),
                _field(_emailCtrl, 'Email (optional)', Icons.email_outlined,
                    type: TextInputType.emailAddress),
              ],
              // City/ZIP/Country — shown whether booking for myself or a guest
              const Divider(height: 1),
              _field(_cityCtrl, 'City (optional)', Icons.location_city_outlined),
              _field(_zipCtrl, 'ZIP Code (optional)', Icons.pin_outlined,
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              _countryPicker(),
            ],
          ),
          const SizedBox(height: 16),
          _amountCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: (_isAvailable == false) ? null : _proceed,
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Proceed to Pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────────

  Widget _availabilityBanner() {
    if (_checkInDate == null || _checkOutDate == null) return const SizedBox.shrink();

    if (_checkingAvailability) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Checking availability…',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
          ],
        ),
      );
    }

    if (_availabilityMessage.isEmpty) return const SizedBox.shrink();

    final isAvail = _isAvailable == true;
    final isLimited = isAvail && _availableCount <= (widget.room.count / 2).ceil();
    final color = !isAvail
        ? Colors.red
        : isLimited
            ? Colors.orange
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            !isAvail
                ? Icons.cancel_rounded
                : isLimited
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_availabilityMessage,
                style: TextStyle(fontSize: 13, color: color.shade700, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _roomHeader(RoomModel room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hotel_rounded, color: Color(0xFF1565C0), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text('${room.type}  •  ${room.capacity}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('${_formatAmount(room.pricePerNight)} / night',
                    style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Icon(icon, size: 18, color: const Color(0xFF1565C0)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _dateRangeTile() {
    final hasRange = _checkInDate != null && _checkOutDate != null;
    return InkWell(
      onTap: _pickDateRange,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, size: 22, color: Color(0xFF1565C0)),
            const SizedBox(width: 14),
            Expanded(
              child: hasRange
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Check-in', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(_formatDate(_checkInDate!),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Check-out', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(_formatDate(_checkOutDate!),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Text('Select check-in & check-out dates',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _nightsSummaryTile() {
    return Container(
      color: const Color(0xFFF0F4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.nights_stay_outlined,
              size: 18, color: Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Text('$_nights night${_nights == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565C0))),
          const SizedBox(width: 8),
          Text(
            '(${_formatDate(_checkInDate!)} → ${_formatDate(_checkOutDate!)})',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _stepperTile(String label, IconData icon, int value, int min, int max,
      {required VoidCallback onDec, required VoidCallback onInc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          _stepBtn(Icons.remove_rounded, value <= min ? null : onDec),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$value',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _stepBtn(Icons.add_rounded, value >= max ? null : onInc),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey.shade100
              : const Color(0xFF1565C0).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: onTap == null
                  ? Colors.grey.shade200
                  : const Color(0xFF1565C0).withValues(alpha: 0.3)),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap == null
                ? Colors.grey.shade400
                : const Color(0xFF1565C0)),
      ),
    );
  }

  Widget _forMyselfToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Expanded(child: _toggleOption('For Myself', true)),
        const SizedBox(width: 8),
        Expanded(child: _toggleOption('For Someone Else', false)),
      ]),
    );
  }

  Widget _toggleOption(String label, bool value) {
    final selected = _forMyself == value;
    return GestureDetector(
      onTap: () => setState(() => _forMyself = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.grey.shade300),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _countryPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: DropdownButtonFormField<String>(
        value: _country,
        decoration: InputDecoration(
          labelText: 'Country',
          prefixIcon: const Icon(Icons.flag_outlined, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
        items: AppCountries.all
            .map((c) => DropdownMenuItem(
                value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (v) => setState(() => _country = v ?? 'India'),
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _amountRow('Room', widget.room.name),
          const SizedBox(height: 6),
          _amountRow('Rate / night', _formatAmount(widget.room.pricePerNight)),
          const SizedBox(height: 6),
          _amountRow('Rooms', '$_rooms'),
          const SizedBox(height: 6),
          _amountRow('Guests', '$_guests'),
          const SizedBox(height: 6),
          _amountRow('Nights', _nights > 0 ? '$_nights' : '—'),
          const Divider(height: 16, color: Color(0xFFFFCC80)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                      fontSize: 14)),
              Text(
                _nights > 0 ? _formatAmount(_total) : '—',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                    fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Date range picker dialog ──────────────────────────────────────────────────

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime? initialEnd;
  final DateTime first;
  final DateTime last;

  const _DateRangePickerDialog({
    required this.initialStart,
    required this.initialEnd,
    required this.first,
    required this.last,
  });

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DateTime _start;
  DateTime? _end;
  // 0 = selecting start, 1 = selecting end
  int _step = 0;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _displayMonth = DateTime(_start.year, _start.month);
    _step = (_end == null) ? 0 : 1;
  }

  bool _isInRange(DateTime d) {
    if (_end == null) return false;
    return d.isAfter(_start) && d.isBefore(_end!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onDayTap(DateTime d) {
    if (d.isBefore(widget.first)) return;
    setState(() {
      if (_step == 0) {
        _start = d;
        _end = null;
        _step = 1;
      } else {
        if (!d.isAfter(_start)) {
          _start = d;
          _end = null;
          _step = 1;
        } else {
          _end = d;
          _step = 0;
        }
      }
    });
  }

  void _prevMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1));
  void _nextMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1));

  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // Monday=1, so offset = (weekday - 1) for Mon-start grid
    final startOffset = (firstDay.weekday - 1) % 7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Dates',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                      const SizedBox(height: 2),
                      Text(
                        _end != null
                            ? '${_formatDate(_start)} → ${_formatDate(_end!)}'
                            : _step == 1
                                ? '${_formatDate(_start)} → Select check-out'
                                : 'Tap a date to start',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (_end != null)
                  TextButton(
                    onPressed: () => setState(() { _end = null; _step = 0; }),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Step indicator
            Row(
              children: [
                _stepChip('1. Check-in', _step == 0),
                const SizedBox(width: 8),
                _stepChip('2. Check-out', _step == 1),
              ],
            ),
            const SizedBox(height: 12),
            // Month nav
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded)),
                Text('${_months[_displayMonth.month]} ${_displayMonth.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
            // Weekday headers
            Row(
              children: _weekdays.map((d) => Expanded(
                child: Center(child: Text(d,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500))),
              )).toList(),
            ),
            const SizedBox(height: 4),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, childAspectRatio: 1),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (_, i) {
                if (i < startOffset) return const SizedBox.shrink();
                final day = DateTime(_displayMonth.year, _displayMonth.month, i - startOffset + 1);
                final isPast = day.isBefore(DateTime(today.year, today.month, today.day));
                final isStart = _isSameDay(day, _start);
                final isEnd = _end != null && _isSameDay(day, _end!);
                final inRange = _isInRange(day);

                Color bg = Colors.transparent;
                Color fg = isPast ? Colors.grey.shade300 : Colors.black87;
                if (isStart || isEnd) {
                  bg = const Color(0xFF1565C0);
                  fg = Colors.white;
                } else if (inRange) {
                  bg = const Color(0xFF1565C0).withValues(alpha: 0.12);
                  fg = const Color(0xFF1565C0);
                }

                return GestureDetector(
                  onTap: isPast ? null : () => _onDayTap(day),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.normal,
                            color: fg,
                          )),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _end == null ? null : () {
                    Navigator.pop(context, DateTimeRange(start: _start, end: _end!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1565C0) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey.shade500)),
    );
  }
}
