import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../constants/countries.dart';
import '../models/order_model.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/pooja_service.dart';
import '../services/room_service.dart';
import 'orders_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_screen.dart';
import '../models/booking_form_data.dart';
import 'package:audioplayers/audioplayers.dart';

const List<String> _kGotras = [
  'Kashyap', 'Bharadwaj', 'Vashistha', 'Sandilya', 'Gautam',
  'Atreya', 'Bharadwaja', 'Kaushik', 'Vatsa', 'Garg',
];

String _shortOrderId(DateTime now) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = math.Random(now.millisecondsSinceEpoch);
  final suffix = List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  return 'TP-$suffix';
}

// ── Booking-for mode ──────────────────────────────────────────────────────────
enum _BookingFor { myself, someoneElse, family }

// ── Internal cart item ────────────────────────────────────────────────────────

class _CartItem {
  String poojaName;
  DateTime? date;
  final TextEditingController gotraCtrl;

  // Private pooja
  bool isPrivatePooja = false;

  // People
  int numberOfPeople = 1;

  // Stay
  bool wantsStay = false;
  int numberOfRooms = 1;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  bool? stayAvailable;
  int stayAvailableCount = 0;
  String stayAvailabilityMessage = '';
  bool checkingStayAvailability = false;

  int get numberOfNights {
    if (checkInDate == null || checkOutDate == null) return 1;
    final diff = checkOutDate!.difference(checkInDate!).inDays;
    return diff > 0 ? diff : 1;
  }

  _CartItem({required this.poojaName, this.date})
      : gotraCtrl = TextEditingController();

  void dispose() => gotraCtrl.dispose();

  int poojaAmount(List poojas, {int familyCount = 1}) {
    final pooja = poojas.where((p) => p.name == poojaName).firstOrNull;
    if (isPrivatePooja && pooja?.privatePooja == true) {
      return pooja?.privatePoojaRate ?? 0;
    }
    return (pooja?.pricePerPerson ?? 0) * familyCount;
  }

  RoomModel? selectedRoom;

  int get stayRate => selectedRoom?.pricePerNight ?? 0;

  int get stayAmount =>
      wantsStay && selectedRoom != null
          ? stayRate * numberOfRooms * numberOfNights
          : 0;

  int totalAmount(List poojas, {int familyCount = 1}) =>
      poojaAmount(poojas, familyCount: familyCount) + stayAmount;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  final String selectedPooja;
  final DateTime? preselectedDate;

  const BookingScreen({super.key, required this.selectedPooja, this.preselectedDate});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<_CartItem> _items;

  // Booking-for
  _BookingFor _bookingFor = _BookingFor.myself;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();   // for someone else
  final _myEmailCtrl = TextEditingController(); // for myself / family
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _country = 'India';
  DateTime? _birthday;

  // Family booking
  final _familyGotraCtrl = TextEditingController();
  final List<TextEditingController> _familyNameCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<DateTime?> _familyDobs = [null, null];

  @override
  void initState() {
    super.initState();
    _items = [_CartItem(poojaName: widget.selectedPooja)];
    if (widget.preselectedDate != null) _items[0].date = widget.preselectedDate;
    RoomService.rooms.addListener(_onRoomsChanged);
    RoomService.isLoading.addListener(_onRoomsChanged);
    RoomService.load(force: true);
    final userEmail = AuthService.currentUser?.email ?? '';
    if (userEmail.isNotEmpty) _myEmailCtrl.text = userEmail;
    _nameCtrl.addListener(() => setState(() {}));
    _familyNameCtrls[0].addListener(() => setState(() {}));
  }

  String get _devoteeDisplayName {
    if (_bookingFor == _BookingFor.myself) {
      return AuthService.currentUser?.fullName ?? '';
    }
    if (_bookingFor == _BookingFor.someoneElse) {
      return _nameCtrl.text.trim();
    }
    if (_bookingFor == _BookingFor.family) {
      final parts = _familyNameCtrls[0].text.trim().split(' ');
      final lastName = parts.length > 1 ? parts.last : '';
      return lastName.isNotEmpty ? '$lastName Family' : '';
    }
    return '';
  }

  void _onRoomsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RoomService.rooms.removeListener(_onRoomsChanged);
    RoomService.isLoading.removeListener(_onRoomsChanged);
    for (final item in _items) {
      item.dispose();
    }
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _myEmailCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _familyGotraCtrl.dispose();
    for (final c in _familyNameCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  List get _poojas => PoojaService.poojas.value;
  List<RoomModel> get _rooms => RoomService.rooms.value;

  int get _grandTotal {
    final fc = _bookingFor == _BookingFor.family ? _familyNameCtrls.length : 1;
    return _items.fold(0, (s, item) => s + item.totalAmount(_poojas, familyCount: fc));
  }

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
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  Future<void> _pickDate(int index) async {
    final item = _items[index];
    final pooja = _poojas.where((p) => p.name == item.poojaName).firstOrNull;
    final muhurtaDates = pooja?.muhurtaDates ?? [];
    final color = pooja?.color ?? AppColors.primary;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MuhurtaDatePickerSheet(
        initialDate: item.date,
        muhurtaDates: muhurtaDates,
        color: AppColors.primary,
      ),
    );

    if (picked != null) setState(() => _items[index].date = picked);
  }

  void _addPooja() {
    final taken = _items.map((e) => e.poojaName).toSet();
    final available = _poojas.where((p) => !taken.contains(p.name)).toList();
    if (available.isEmpty) return;
    setState(() => _items.add(_CartItem(poojaName: available.first.name)));
  }

  void _removePooja(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  bool _processing = false;

  Future<void> _bookNow() async {
    // ── Require complete profile before booking ───────────────────────────────
    final user = AuthService.currentUser!;
    final missingFields = <String>[];
    final name = user.fullName.trim().toLowerCase();
    if (name.isEmpty || name == 'guest' || name == 'user')
      missingFields.add('• Full Name');
    if (user.phone.trim().length < 10) missingFields.add('• Phone Number');
    if (user.email.trim().isEmpty || !user.email.contains('@'))
      missingFields.add('• Email ID');

    if (missingFields.isNotEmpty) {
      await showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        builder: (ctx) => _GlassProfileDialog(
          missingFields: missingFields,
          onUpdate: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  initialEmail: _myEmailCtrl.text.trim().isEmpty ? null : _myEmailCtrl.text.trim(),
                ),
              ),
            );
          },
          onCancel: () => Navigator.pop(ctx),
        ),
      );
      return;
    }
    // ─────────────────────────────────────────────────────────────────────────

    if (_bookingFor == _BookingFor.family) {
      for (int i = 0; i < _familyNameCtrls.length; i++) {
        if (_familyNameCtrls[i].text.trim().isEmpty) {
          _snack('Please enter name for family member ${i + 1}');
          return;
        }
      }
    }
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].date == null) {
        _snack('Please select a date for ${_items[i].poojaName}');
        return;
      }
      if (_items[i].wantsStay) {
        if (_items[i].selectedRoom == null) {
          _snack('Please select a room type for ${_items[i].poojaName}');
          return;
        }
        if (_items[i].checkInDate == null) {
          _snack('Please select check-in & check-out dates for your stay');
          return;
        }
        if (_items[i].checkOutDate == null) {
          _snack('Please select a check-out date for your stay');
          return;
        }
        if (_items[i].stayAvailable == false) {
          _snack('${_items[i].selectedRoom!.name} is fully booked for the selected dates. Please choose different dates.');
          return;
        }
        if (_items[i].checkingStayAvailability) {
          _snack('Please wait while we check room availability…');
          return;
        }
      }
    }

    if (_bookingFor == _BookingFor.someoneElse) {
      if (_nameCtrl.text.trim().isEmpty) {
        _snack('Please enter the person\'s name');
        return;
      }
      if (_phoneCtrl.text.trim().isEmpty) {
        _snack('Please enter the person\'s mobile number');
        return;
      }
    }

    // Build BookingFormData and navigate to PaymentScreen
    final fc = _bookingFor == _BookingFor.family ? _familyNameCtrls.length : 1;
    final entries = _items.map((item) {
      final color = _poojas.where((p) => p.name == item.poojaName).firstOrNull?.color ?? AppColors.primary;
      return BookingEntry(
        bookingType: 'pooja',
        poojaName: item.poojaName,
        poojaDate: item.date,
        checkInDate: item.wantsStay ? item.checkInDate : null,
        gotra: _bookingFor == _BookingFor.family
            ? _familyGotraCtrl.text.trim()
            : item.gotraCtrl.text.trim(),
        poojaAmount: item.poojaAmount(_poojas, familyCount: fc),
        isPrivatePooja: item.isPrivatePooja,
        poojaColor: color,
        numberOfRooms: item.wantsStay ? item.numberOfRooms : 0,
        numberOfNights: item.wantsStay ? item.numberOfNights : 0,
        numberOfGuests: _bookingFor == _BookingFor.family ? fc : item.numberOfPeople,
        stayRatePerRoom: item.wantsStay ? item.stayRate : 0,
        selectedRoomId: item.wantsStay ? item.selectedRoom?.id : null,
        selectedRoomName: item.wantsStay ? item.selectedRoom?.name : null,
      );
    }).toList();

    final formData = BookingFormData(
      entries: entries,
      forMyself: _bookingFor != _BookingFor.someoneElse,
      bookedForName: _bookingFor == _BookingFor.someoneElse ? _nameCtrl.text.trim() : null,
      bookedForPhone: _bookingFor == _BookingFor.someoneElse ? _phoneCtrl.text.trim() : null,
      bookedForEmail: _bookingFor == _BookingFor.someoneElse
          ? (_emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim())
          : (_myEmailCtrl.text.trim().isEmpty ? null : _myEmailCtrl.text.trim()),
      bookedForCity: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      bookedForZipCode: _zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim(),
      bookedForCountry: _country,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(data: formData)),
    );
  }

  void _showBookingToast(String firstOrderId) {
    HapticFeedback.heavyImpact();

    bool dismissed = false;
    OverlayEntry? entry;

    void goToOrders() {
      if (dismissed) return;
      dismissed = true;
      entry?.remove();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OrdersScreen(openDetailForOrderId: firstOrderId, backToPoojas: true)),
        (_) => false,
      );
    }

    void dismiss() => goToOrders();

    final fc = _bookingFor == _BookingFor.family ? _familyNameCtrls.length : 0;
    final familyInfo = fc > 0 ? '$fc family members' : '';
    final poojaName = _items.length == 1
        ? _items.first.poojaName
        : _items.map((e) => e.poojaName).join(', ');
    final date = _items.first.date != null ? _formatDate(_items.first.date!) : '';

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
                  onTap: () {}, // absorb taps on the card itself
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _BookingToastOverlay(
                      poojaName: poojaName,
                      date: date,
                      total: _formatAmount(_grandTotal),
                      familyInfo: familyInfo,
                      onDismiss: dismiss,
                      onViewDetails: () {
                        dismiss();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrdersScreen(highlightOrderId: firstOrderId),
                          ),
                        );
                      },
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

  void _snack(String msg) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CentreToast(
        message: msg,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.appBarGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppL10n.s.bookingFormTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          _items.map((e) => e.poojaName).join(', '),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_grandTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _formatAmount(_grandTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBookingForCard(),
                const SizedBox(height: 14),
                _buildLocationCard(),
                const SizedBox(height: 14),
                ...List.generate(
                  _items.length,
                  (i) => Column(children: [
                    _buildPoojaCard(i),
                    const SizedBox(height: 14),
                  ]),
                ),
                const SizedBox(height: 14),
                _buildCostSummary(),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
              child: ElevatedButton(
                onPressed: _processing ? null : _bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
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
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        '${AppL10n.s.bookNow}  ${_formatAmount(_grandTotal)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section: Booking For ──────────────────────────────────────────────────────

  Widget _buildBookingForCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              const Text('Booking For',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              if (_devoteeDisplayName.isNotEmpty) ...[
                const Text(' - ',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Flexible(
                  child: Text(
                    _devoteeDisplayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _forToggle('Me', _BookingFor.myself)),
              const SizedBox(width: 8),
              Expanded(child: _forToggle('Others', _BookingFor.someoneElse)),
              const SizedBox(width: 8),
              Expanded(child: _forToggle('For Family', _BookingFor.family)),
            ],
          ),
          const SizedBox(height: 16),
          _textField(
              controller: _myEmailCtrl,
              hint: 'Your Email (for booking confirmation)',
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress),
          if (_bookingFor == _BookingFor.myself) ...[
            const SizedBox(height: 10),
            _birthdayTile(),
          ],
          // ── Someone Else fields ──
          if (_bookingFor == _BookingFor.someoneElse) ...[
            const SizedBox(height: 16),
            _textField(
                controller: _nameCtrl,
                hint: AppL10n.s.fullName,
                icon: Icons.person_outline,
                caps: TextCapitalization.words),
            const SizedBox(height: 10),
            _textField(
                controller: _phoneCtrl,
                hint: AppL10n.s.phoneNumber,
                icon: Icons.phone_outlined,
                type: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 10),
            _textField(
                controller: _emailCtrl,
                hint: 'Their Email (optional)',
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _birthdayTile(),
          ],
          // ── Family fields ──
          if (_bookingFor == _BookingFor.family) ...[
            const SizedBox(height: 14),
            _GotraField(
              controller: _familyGotraCtrl,
              hint: 'Family Gotra — Optional (same for all members)',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                const Text('Family Members',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const Spacer(),
                Text('${_familyNameCtrls.length} members',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey500)),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_familyNameCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                              controller: _familyNameCtrls[i],
                              hint: 'Member ${i + 1} Full Name',
                              icon: Icons.person_outline,
                              caps: TextCapitalization.words),
                        ),
                        if (_familyNameCtrls.length > 2) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _familyNameCtrls[i].dispose();
                              _familyNameCtrls.removeAt(i);
                              if (i < _familyDobs.length) _familyDobs.removeAt(i);
                            }),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Icon(Icons.close,
                              size: 16, color: Colors.red.shade400),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                _memberDobTile(i),
              ],
            ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() {
                _familyNameCtrls.add(TextEditingController());
                _familyDobs.add(null);
              }),
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text('Add Member'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _personToggle(int n, _CartItem item) {
    final selected = item.numberOfPeople == n;
    return GestureDetector(
      onTap: () => setState(() => item.numberOfPeople = n),
      child: Container(
        width: 44,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$n',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  Widget _forToggle(String label, _BookingFor value) {
    return _ForToggleButton(
      label: label,
      selected: _bookingFor == value,
      onTap: () => setState(() => _bookingFor = value),
    );
  }

  // ── Section: Pooja Card ───────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.location_on_outlined, 'Location'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _CityField(controller: _cityCtrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _CountryChip(
                  value: _country,
                  onChanged: (v) => setState(() => _country = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoojaCard(int index) {
    final item = _items[index];
    final pooja =
        _poojas.where((p) => p.name == item.poojaName).firstOrNull;
    const color = AppColors.primary;
    final maxNights = pooja?.durationDays ?? 1;

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

          // Pooja dropdown + Date in same row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _PoojaSelector(
                  selected: item.poojaName,
                  options: _poojas
                      .where((p) {
                        final takenByOthers = _items
                            .asMap()
                            .entries
                            .where((e) => e.key != index)
                            .map((e) => e.value.poojaName)
                            .toSet();
                        return !takenByOthers.contains(p.name);
                      })
                      .map((p) => p.name)
                      .toList()
                      .cast<String>(),
                  color: color,
                  onChanged: (v) => setState(() => item.poojaName = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _pickDate(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.date == null
                                ? AppL10n.s.dateLabel
                                : _formatDate(item.date!),
                            style: TextStyle(
                              fontSize: 13,
                              color: item.date == null
                                  ? Colors.grey.shade500
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.grey500, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Gotra — hidden for family (shared gotra entered above)
          if (_bookingFor != _BookingFor.family) ...[
            _GotraField(
              controller: item.gotraCtrl,
              hint: 'Enter Gotra (Optional)',
            ),
            const SizedBox(height: 12),
          ],

          // Number of people
          if (_bookingFor == _BookingFor.family) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(AppL10n.s.numberOfPersons,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grey700)),
                  const Spacer(),
                  Text(
                    '${_familyNameCtrls.length} members',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Row(
              children: [
                Icon(Icons.people_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(AppL10n.s.numberOfPersons,
                    style: const TextStyle(fontSize: 13, color: AppColors.grey700)),
                const Spacer(),
                _personToggle(1, item),
                const SizedBox(width: 8),
                _personToggle(2, item),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Private pooja toggle — only shown when admin has enabled it
          if (pooja?.privatePooja == true)
            _PrivatePoojaCard(
              color: color,
              rate: pooja?.privatePoojaRate ?? 0,
              isSelected: item.isPrivatePooja,
              formatAmount: _formatAmount,
              enabled: true,
              onChanged: (v) => setState(() => item.isPrivatePooja = v),
            ),
          const SizedBox(height: 10),

          // Pooja rate row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _bookingFor == _BookingFor.family
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_familyNameCtrls.length} × ${_formatAmount(item.poojaAmount(_poojas))}',
                            style: TextStyle(fontSize: 12, color: color),
                          ),
                          Text(
                            _formatAmount(item.poojaAmount(_poojas,
                                familyCount: _familyNameCtrls.length)),
                            style: TextStyle(
                                fontSize: 14,
                                color: color,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.isPrivatePooja
                            ? 'Private Pooja Rate'
                            : 'Pooja Rate',
                        style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _formatAmount(item.poojaAmount(_poojas)),
                        style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),

          // Add another pooja — only on the last card
          if (index == _items.length - 1 &&
              _items.length < _poojas.length) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _addPooja,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Another Pooja'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],

          // ── Stay section ────────────────────────────────────────────────
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Stay toggle
          GestureDetector(
            onTap: () {
              final v = !item.wantsStay;
              if (v && _rooms.isEmpty) RoomService.load(force: true);
              setState(() => item.wantsStay = v);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D01E8), Color(0xFF3136D5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hotel_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppL10n.s.stayRequired,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        if (RoomService.isLoading.value)
                          const Text('Loading rooms…',
                              style: TextStyle(fontSize: 11, color: Colors.white70)),
                        if (!RoomService.isLoading.value && _rooms.isEmpty)
                          const Text('No rooms available at the moment',
                              style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: item.wantsStay,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white30,
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: Colors.white24,
                    onChanged: (v) {
                      if (v && _rooms.isEmpty) RoomService.load(force: true);
                      setState(() => item.wantsStay = v);
                    },
                  ),
                ],
              ),
            ),
          ),

          if (item.wantsStay && _rooms.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.sync_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    RoomService.isLoading.value
                        ? 'Loading available rooms…'
                        : 'Could not load rooms. Tap to retry.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (!RoomService.isLoading.value) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => RoomService.load(force: true),
                      child: Text('Retry',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),

          if (item.wantsStay && _rooms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Select Room Type',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700),
            ),
            const SizedBox(height: 8),

            // Room type cards – horizontal scroll
            SizedBox(
              height: 164,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: _rooms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) =>
                    _roomTypeCard(item, _rooms[i], color, i),
              ),
            ),

            if (item.selectedRoom != null) ...[
              const SizedBox(height: 12),
              Text(
                '${item.selectedRoom!.capacity}  ·  ${item.selectedRoom!.count} rooms available',
                style: TextStyle(fontSize: 11, color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              // Combined check-in / check-out date picker
              _stayDateRangeTile(item: item, color: color),
              if (item.checkInDate != null && item.checkOutDate != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.nights_stay_outlined, size: 14, color: color),
                      const SizedBox(width: 6),
                      Text(
                        '${item.numberOfNights} night${item.numberOfNights == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Availability banner
              if (item.checkInDate != null && item.checkOutDate != null)
                _stayAvailabilityBanner(item),
              const SizedBox(height: 10),
              _stayCounter(
                icon: Icons.meeting_room_outlined,
                label: 'Rooms',
                value: item.numberOfRooms,
                min: 1,
                max: item.stayAvailable == true
                    ? item.stayAvailableCount
                    : item.selectedRoom!.availableCount,
                disabled: item.checkInDate == null ||
                    item.checkOutDate == null ||
                    item.checkingStayAvailability ||
                    item.stayAvailable == false,
                onDecrement: () => setState(() => item.numberOfRooms--),
                onIncrement: () {
                  final maxRooms = item.stayAvailable == true
                      ? item.stayAvailableCount
                      : item.selectedRoom!.availableCount;
                  if (item.numberOfRooms >= maxRooms) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Only $maxRooms room(s) available for these dates'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                    return;
                  }
                  setState(() => item.numberOfRooms++);
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item.stayRate} × ${item.numberOfRooms}rm × ${item.numberOfNights}n',
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _formatAmount(item.stayAmount),
                      style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _fmtStayDate(DateTime d) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  Widget _stayDateTile({
    required IconData icon,
    required String label,
    required DateTime? value,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.3) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? color.withValues(alpha: 0.04) : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16,
                color: enabled ? color : Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: enabled ? Colors.grey.shade600 : Colors.grey.shade400)),
                  Text(
                    value != null ? _fmtStayDate(value) : 'Tap to select',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: value != null
                            ? Colors.black87
                            : enabled
                                ? Colors.grey.shade500
                                : Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16,
                color: enabled ? Colors.grey.shade400 : Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

  Widget _stayAvailabilityBanner(_CartItem item) {
    if (item.checkingStayAvailability) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Checking availability…',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
      );
    }
    if (item.stayAvailabilityMessage.isEmpty) return const SizedBox.shrink();
    final isAvail = item.stayAvailable == true;
    final isLimited = isAvail && item.stayAvailableCount == 1;
    final color = !isAvail ? Colors.red : isLimited ? Colors.orange : Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            !isAvail ? Icons.cancel_rounded
                : isLimited ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(item.stayAvailabilityMessage,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStayDateRange(_CartItem item) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Default check-in to one day before pooja date if not already set
    DateTime defaultStart = today;
    if (item.checkInDate == null && item.date != null) {
      final dayBefore = item.date!.subtract(const Duration(days: 1));
      defaultStart = dayBefore.isBefore(today) ? today : dayBefore;
    } else {
      defaultStart = item.checkInDate ?? today;
    }

    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (_) => _DateRangePickerDialog(
        initialStart: defaultStart,
        initialEnd: item.checkOutDate ?? (item.date ?? defaultStart.add(const Duration(days: 1))),
        first: today,
        last: DateTime(now.year + 2),
      ),
    );
    if (result == null) return;
    final checkIn = result.start;
    final checkOut = result.end.isAfter(result.start)
        ? result.end
        : result.start.add(const Duration(days: 1));
    setState(() {
      item.checkInDate = checkIn;
      item.checkOutDate = checkOut;
      item.stayAvailable = null;
      item.stayAvailableCount = 0;
      item.stayAvailabilityMessage = '';
      item.checkingStayAvailability = item.selectedRoom != null;
    });

    // Warn if stay dates are far from pooja date
    if (item.date != null) {
      final poojaDay = DateTime(item.date!.year, item.date!.month, item.date!.day);
      final stayStart = DateTime(checkIn.year, checkIn.month, checkIn.day);
      final stayEnd = DateTime(checkOut.year, checkOut.month, checkOut.day);
      final isNear = !(stayEnd.isBefore(poojaDay.subtract(const Duration(days: 3))) ||
          stayStart.isAfter(poojaDay.add(const Duration(days: 3))));
      if (!isNear) {
        _snack('Your stay dates are far from your Pooja date. Please confirm your dates.');
      }
    }

    if (item.selectedRoom == null) return;
    await _checkStayAvailability(item, checkIn, checkOut);
  }

  Future<void> _checkStayAvailability(_CartItem item, DateTime checkIn, DateTime checkOut) async {
    if (item.selectedRoom == null) return;
    setState(() => item.checkingStayAvailability = true);
    final result = await ApiService.checkRoomAvailability(
        item.selectedRoom!.id.toString(), checkIn, checkOut);
    if (!mounted) return;
    setState(() {
      item.checkingStayAvailability = false;
      item.stayAvailable = result.available;
      item.stayAvailableCount = result.availableCount;
      item.stayAvailabilityMessage = result.message;
      // Clamp rooms to available
      if (result.available && result.availableCount > 0 &&
          item.numberOfRooms > result.availableCount) {
        item.numberOfRooms = result.availableCount;
      }
    });
  }

  Widget _stayDateRangeTile({required _CartItem item, required Color color}) {
    final hasRange = item.checkInDate != null && item.checkOutDate != null;
    return InkWell(
      onTap: () => _pickStayDateRange(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: hasRange
                  ? Text(
                      '${_fmtDate(item.checkInDate!)}  →  ${_fmtDate(item.checkOutDate!)}',
                      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
                    )
                  : Text(
                      'Select check-in & check-out dates',
                      style: TextStyle(fontSize: 13, color: AppColors.grey500),
                    ),
            ),
            Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => _bsFmtDate(d);

  Widget _stayCounter({
    required IconData icon,
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool disabled = false,
  }) {
    final iconColor = disabled ? AppColors.grey300 : AppColors.primary;
    final textColor = disabled ? AppColors.grey500 : AppColors.grey700;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor)),
          const Spacer(),
          IconButton(
            onPressed: disabled || value <= min ? null : onDecrement,
            icon: const Icon(Icons.remove_circle_outline),
            color: disabled || value <= min ? AppColors.grey300 : AppColors.primary,
            iconSize: 24,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 36,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: disabled ? AppColors.grey500 : Colors.black87)),
          ),
          IconButton(
            onPressed: disabled || value >= max ? null : onIncrement,
            icon: const Icon(Icons.add_circle_outline),
            color: disabled || value >= max ? AppColors.grey300 : AppColors.primary,
            iconSize: 24,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  // ── Room type selection card ──────────────────────────────────────────────────

  static const _roomPalette = [
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFF00695C),
    Color(0xFF6A1B9A), Color(0xFFE65100), Color(0xFF880E4F),
  ];

  Widget _roomTypeCard(_CartItem item, RoomModel room, Color poojaColor, int index) {
    final selected = item.selectedRoom?.id == room.id;
    final roomColor = _roomPalette[index % _roomPalette.length];

    return GestureDetector(
      onTap: () {
        setState(() {
          item.selectedRoom = room;
          if (item.numberOfRooms > room.count) item.numberOfRooms = 1;
          item.stayAvailable = null;
          item.stayAvailabilityMessage = '';
        });
        if (item.checkInDate != null && item.checkOutDate != null) {
          _checkStayAvailability(item, item.checkInDate!, item.checkOutDate!);
        }
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? poojaColor : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? poojaColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: selected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    room.imageUrl.isNotEmpty
                        ? Image.network(room.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _roomCardFallback(roomColor))
                        : _roomCardFallback(roomColor),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: room.type == 'AC'
                              ? const Color(0xFF1565C0)
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(room.type,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                              color: poojaColor, shape: BoxShape.circle),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '₹${room.pricePerNight}/night',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: roomColor),
                      ),
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 10, color: AppColors.grey500),
                          const SizedBox(width: 3),
                          Text(room.capacity,
                              style: TextStyle(
                                  fontSize: 9.5, color: AppColors.grey500)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.meeting_room_outlined,
                              size: 10, color: AppColors.grey500),
                          const SizedBox(width: 3),
                          Text('${room.count} avail.',
                              style: TextStyle(
                                  fontSize: 9.5, color: AppColors.grey500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomCardFallback(Color color) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.hotel_outlined,
              size: 26, color: Colors.white.withValues(alpha: 0.5)),
        ),
      );

  // ── Section: Cost Summary ─────────────────────────────────────────────────────

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
                    color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text('Cost Summary',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
          const SizedBox(height: 14),
          ..._items.map((item) {
            final fc = _bookingFor == _BookingFor.family
                ? _familyNameCtrls.length
                : 1;
            final stayAmt = item.stayAmount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.poojaName,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.grey700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_bookingFor == _BookingFor.family)
                              Text(
                                '$fc × ${_formatAmount(item.poojaAmount(_poojas))}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.grey500),
                              ),
                          ],
                        ),
                      ),
                      Text(
                          _formatAmount(
                              item.poojaAmount(_poojas, familyCount: fc)),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (item.wantsStay && stayAmt > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.selectedRoom?.name ?? 'Stay'} (${item.numberOfRooms}rm × ${item.numberOfNights}n)',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(_formatAmount(stayAmt),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey700)),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
          Divider(color: color.withValues(alpha: 0.3), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _items.length > 1 ? 'Grand Total' : AppL10n.s.totalAmount,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                _formatAmount(_grandTotal),
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Reusable widgets ──────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

  Widget _memberDobTile(int index) {
    while (_familyDobs.length <= index) _familyDobs.add(null);
    final dob = _familyDobs[index];
    final formatted = dob == null
        ? null
        : '${dob.day.toString().padLeft(2, '0')} / ${dob.month.toString().padLeft(2, '0')} / ${dob.year}';
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: dob ?? DateTime(now.year - 30),
          firstDate: DateTime(1900),
          lastDate: now,
          helpText: 'Member ${index + 1} Date of Birth',
        );
        if (picked != null) setState(() => _familyDobs[index] = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted ?? 'Date of Birth (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: formatted != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
            if (dob != null)
              GestureDetector(
                onTap: () => setState(() => _familyDobs[index] = null),
                child: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _birthdayTile() {
    final formatted = _birthday == null
        ? null
        : '${_birthday!.day.toString().padLeft(2, '0')} / ${_birthday!.month.toString().padLeft(2, '0')} / ${_birthday!.year}';
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthday ?? DateTime(now.year - 30),
          firstDate: DateTime(1900),
          lastDate: now,
          helpText: 'Select Date of Birth',
        );
        if (picked != null) setState(() => _birthday = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted ?? 'Date of Birth (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: formatted != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
            if (_birthday != null)
              GestureDetector(
                onTap: () => setState(() => _birthday = null),
                child: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
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

// ── Private Pooja Card with pulsing glow ─────────────────────────────────────

class _PrivatePoojaCard extends StatefulWidget {
  final Color color;
  final int rate;
  final bool isSelected;
  final bool enabled;
  final String Function(int) formatAmount;
  final ValueChanged<bool>? onChanged;

  const _PrivatePoojaCard({
    required this.color,
    required this.rate,
    required this.isSelected,
    required this.formatAmount,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<_PrivatePoojaCard> createState() => _PrivatePoojaCardState();
}

class _PrivatePoojaCardState extends State<_PrivatePoojaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _activeBlue = Color(0xFF1D87E4);

  @override
  Widget build(BuildContext context) {
    // Disabled state — pooja doesn't support private booking
    if (!widget.enabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_person_outlined, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Private / Separate Pooja',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  Text('Not available for this pooja',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
            Switch.adaptive(value: false, onChanged: null),
          ],
        ),
      );
    }

    if (widget.isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _activeBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _activeBlue, width: 1.5),
        ),
        child: _row(_activeBlue),
      );
    }

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        final bgAlpha = 0.04 + _glow.value * 0.08;
        final borderAlpha = 0.3 + _glow.value * 0.5;
        final blurRadius = 4.0 + _glow.value * 10.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _activeBlue.withValues(alpha: bgAlpha),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _activeBlue.withValues(alpha: borderAlpha),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _activeBlue.withValues(alpha: _glow.value * 0.25),
                blurRadius: blurRadius,
                spreadRadius: 0,
              ),
            ],
          ),
          child: _row(AppColors.grey800),
        );
      },
    );
  }

  Widget _row(Color textColor) {
    return Row(
      children: [
        Icon(Icons.lock_person_outlined,
            size: 18,
            color: widget.isSelected ? _activeBlue : AppColors.grey500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Private / Separate Pooja',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              Text(widget.formatAmount(widget.rate),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected ? _activeBlue : AppColors.grey800)),
            ],
          ),
        ),
        Switch.adaptive(
          value: widget.isSelected,
          activeColor: _activeBlue,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

// ── Centre validation toast ───────────────────────────────────────────────────

class _CentreToast extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _CentreToast({required this.message, required this.onDone});

  @override
  State<_CentreToast> createState() => _CentreToastState();
}

class _CentreToastState extends State<_CentreToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xDD212121),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated booking confirmation toast ───────────────────────────────────────

class _BookingToastOverlay extends StatefulWidget {
  final String poojaName;
  final String date;
  final String total;
  final String familyInfo;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const _BookingToastOverlay({
    required this.poojaName,
    required this.date,
    required this.total,
    required this.familyInfo,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  State<_BookingToastOverlay> createState() => _BookingToastOverlayState();
}

class _BookingToastOverlayState extends State<_BookingToastOverlay>
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
    _fadeAnim =
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);
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
          // OM watermark
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
                Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(height: 10),
                _row(Icons.auto_awesome_outlined, widget.poojaName),
                if (widget.date.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _row(Icons.calendar_today_outlined, widget.date),
                ],
                if (widget.familyInfo.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _row(Icons.people_outline, widget.familyInfo),
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
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'View Booking Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Booking-for toggle button with rotating gradient border ──────────────────

class _ForToggleButton extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ForToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ForToggleButton> createState() => _ForToggleButtonState();
}

class _ForToggleButtonState extends State<_ForToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.selected) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(_ForToggleButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.repeat();
    } else if (!widget.selected && old.selected) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => CustomPaint(
          painter: widget.selected
              ? _RotatingBorderPainter(rotation: _ctrl.value)
              : null,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: widget.selected
                ? null
                : Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.selected ? AppColors.primary : AppColors.grey700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double rotation; // 0.0 → 1.0 per full revolution

  const _RotatingBorderPainter({required this.rotation});

  static const _strokeW = 2.5;
  static const _radius = 10.0;

  // Full HSL hue sweep — all colours around the border simultaneously
  static const _colors = [
    Color(0xFFFF0000), // red
    Color(0xFFFF7F00), // orange
    Color(0xFFFFFF00), // yellow
    Color(0xFF00FF00), // green
    Color(0xFF00FFFF), // cyan
    Color(0xFF0000FF), // blue
    Color(0xFF8B00FF), // violet
    Color(0xFFFF00FF), // magenta
    Color(0xFFFF0000), // red — closes the loop
  ];

  static const _stops = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    const half = _strokeW / 2;
    final rect = Rect.fromLTWH(half, half, size.width - _strokeW, size.height - _strokeW);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius - half));

    final angle = rotation * 2 * math.pi;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeW
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + 2 * math.pi,
        colors: _colors,
        stops: _stops,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RotatingBorderPainter old) => old.rotation != rotation;
}

// ── Muhurta-aware date picker bottom sheet ─────────────────────────────────────

class _MuhurtaDatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final List<DateTime> muhurtaDates;
  final Color color;

  const _MuhurtaDatePickerSheet({
    this.initialDate,
    required this.muhurtaDates,
    required this.color,
  });

  @override
  State<_MuhurtaDatePickerSheet> createState() => _MuhurtaDatePickerSheetState();
}

class _MuhurtaDatePickerSheetState extends State<_MuhurtaDatePickerSheet> {
  late DateTime _focusedMonth;
  DateTime? _selected;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selected = widget.initialDate != null
        ? DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day)
        : null;

    // Start on earliest upcoming muhurta, or today
    final upcoming = widget.muhurtaDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .where((d) => !d.isBefore(today))
        .toList()
      ..sort();
    final start = _selected ?? (upcoming.isNotEmpty ? upcoming.first : today);
    _focusedMonth = DateTime(start.year, start.month);
  }

  bool _isMuhurta(DateTime day) => widget.muhurtaDates.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstOfMonth.weekday % 7; // Sun=0
    final canGoPrev = _focusedMonth.isAfter(DateTime(today.year, today.month, 1));

    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Pooja Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: canGoPrev
                    ? () => setState(() => _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1))
                    : null,
                color: canGoPrev ? AppColors.grey800 : AppColors.grey300,
              ),
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(() => _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                color: AppColors.grey800,
              ),
            ],
          ),
          // Day-of-week headers
          Row(
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startOffset) return const SizedBox.shrink();
              final day = DateTime(_focusedMonth.year, _focusedMonth.month,
                  index - startOffset + 1);
              final isPast = day.isBefore(today);
              final isToday = day == today;
              final isMuhurta = _isMuhurta(day);
              final isSelected = _selected != null && day == _selected;

              Color? bgColor;
              Color textColor = AppColors.grey700;
              FontWeight fontWeight = FontWeight.normal;

              if (isSelected) {
                bgColor = widget.color;
                textColor = Colors.white;
                fontWeight = FontWeight.bold;
              } else if (isMuhurta && !isPast) {
                bgColor = Colors.orange.withValues(alpha: 0.18);
                textColor = Colors.orange.shade800;
                fontWeight = FontWeight.bold;
              } else if (isPast) {
                textColor = AppColors.grey300;
              }

              return GestureDetector(
                onTap: isPast ? null : () {
                  setState(() => _selected = day);
                  Navigator.of(context).pop(day);
                },
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: widget.color, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: fontWeight,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          if (widget.muhurtaDates.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.shade800, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppL10n.s.muhurtaLegendNote,
                      style: TextStyle(fontSize: 11.5, color: Colors.orange.shade900, height: 1.4),
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

// ── Stay date picker dialog ───────────────────────────────────────────────────

class _StayDateDialog extends StatefulWidget {
  final String title;
  final DateTime initial;
  final DateTime first;
  final void Function(DateTime) onConfirm;

  const _StayDateDialog({
    required this.title,
    required this.initial,
    required this.first,
    required this.onConfirm,
  });

  @override
  State<_StayDateDialog> createState() => _StayDateDialogState();
}

class _StayDateDialogState extends State<_StayDateDialog> {
  late DateTime _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: _picked,
              firstDate: widget.first,
              lastDate: DateTime(widget.first.year + 2),
              onDateChanged: (d) => setState(() => _picked = d),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_picked);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
}

// ── Glassmorphic "Complete Your Profile" dialog ───────────────────────────────
class _GlassProfileDialog extends StatelessWidget {
  final List<String> missingFields;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;

  const _GlassProfileDialog({
    required this.missingFields,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.18),
                    blurRadius: 32,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon badge ──────────────────────────────────────
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8F00), Color(0xFFBF360C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8F00)
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_outline,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 18),
                      // ── Title ───────────────────────────────────────────
                      const Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please add the following details\nbefore booking:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // ── Missing field rows ──────────────────────────────
                      ...missingFields.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.cancel_outlined,
                                  color: Color(0xFFFFCC80), size: 17),
                              const SizedBox(width: 10),
                              Text(
                                f.startsWith('• ') ? f.substring(2) : f,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // ── Buttons ─────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: onCancel,
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Colors.white.withValues(alpha: 0.75),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: 0.3)),
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E88E5),
                                    Color(0xFF0D47A1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1565C0)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: onUpdate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Date range helpers ────────────────────────────────────────────────────────

String _bsFmt2(int n) => n.toString().padLeft(2, '0');

String _bsFmtDate(DateTime d) =>
    '${_bsFmt2(d.day)} ${_bsMonthName(d.month)} ${d.year}';

String _bsMonthName(int m) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][m];

// ── Combined check-in / check-out calendar dialog ────────────────────────────

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
    final startOffset = (firstDay.weekday - 1) % 7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                            ? '${_bsFmtDate(_start)} → ${_bsFmtDate(_end!)}'
                            : _step == 1
                                ? '${_bsFmtDate(_start)} → Select check-out'
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
            Row(
              children: [
                _stepChip('1. Check-in', _step == 0),
                const SizedBox(width: 8),
                _stepChip('2. Check-out', _step == 1),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded)),
                Text('${_months[_displayMonth.month]} ${_displayMonth.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
            Row(
              children: _weekdays.map((d) => Expanded(
                child: Center(child: Text(d,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500))),
              )).toList(),
            ),
            const SizedBox(height: 4),
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

// ── Pooja Selector (M3 style) ─────────────────────────────────────────────────

class _PoojaSelector extends StatelessWidget {
  const _PoojaSelector({
    required this.selected,
    required this.options,
    required this.color,
    required this.onChanged,
  });

  final String selected;
  final List<String> options;
  final Color color;
  final ValueChanged<String> onChanged;

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PoojaPickerSheet(
        selected: selected,
        options: options,
        color: color,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PoojaPickerSheet extends StatelessWidget {
  const _PoojaPickerSheet({
    required this.selected,
    required this.options,
    required this.color,
    required this.onChanged,
  });

  final String selected;
  final List<String> options;
  final Color color;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text('Select Pooja',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: options.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 56,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (_, i) {
              final opt = options[i];
              final isSelected = opt == selected;
              return InkWell(
                onTap: () {
                  onChanged(opt);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.12)
                              : Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected ? color : Colors.grey.shade400,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ── City autocomplete ─────────────────────────────────────────────────────────

class _CityField extends StatefulWidget {
  const _CityField({required this.controller});
  final TextEditingController controller;
  @override
  State<_CityField> createState() => _CityFieldState();
}

class _CityFieldState extends State<_CityField> {
  TextEditingController? _inner;
  void _sync() { if (_inner != null) widget.controller.text = _inner!.text; }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (v) {
        if (v.text.isEmpty) return const [];
        final q = v.text.toLowerCase();
        return AppCountries.indianCities.where((c) => c.toLowerCase().contains(q));
      },
      fieldViewBuilder: (ctx, ctrl, focus, submit) {
        if (_inner != ctrl) {
          _inner?.removeListener(_sync);
          _inner = ctrl..addListener(_sync);
          if (widget.controller.text.isNotEmpty) ctrl.text = widget.controller.text;
        }
        return TextField(
          controller: ctrl,
          focusNode: focus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'City (optional)',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          onSubmitted: (_) => submit(),
        );
      },
      onSelected: (v) => widget.controller.text = v,
      optionsViewBuilder: (ctx, onSel, opts) => _autocompleteOptions(opts, onSel),
    );
  }

  @override
  void dispose() { _inner?.removeListener(_sync); super.dispose(); }
}

// ── Country autocomplete ──────────────────────────────────────────────────────

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selected: value, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey500, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;
  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _search = TextEditingController();
  List<String> _filtered = AppCountries.all;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? AppCountries.all
            : AppCountries.all.where((c) => c.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search country…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _search.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No results', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 50,
                      color: Colors.grey.shade100,
                    ),
                    itemBuilder: (_, i) {
                      final country = _filtered[i];
                      final isSelected = country == widget.selected;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(country);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 13),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                size: 20,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  country,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

Widget _autocompleteOptions(
    Iterable<String> options, AutocompleteOnSelected<String> onSelected) {
  return Align(
    alignment: Alignment.topLeft,
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, i) {
            final opt = options.elementAt(i);
            return InkWell(
              onTap: () => onSelected(opt),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(opt, style: const TextStyle(fontSize: 14)),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _GotraField extends StatefulWidget {
  const _GotraField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  State<_GotraField> createState() => _GotraFieldState();
}

class _GotraFieldState extends State<_GotraField> {
  TextEditingController? _innerCtrl;

  void _onInnerChanged() {
    if (_innerCtrl != null) widget.controller.text = _innerCtrl!.text;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue v) {
        if (v.text.isEmpty) return const [];
        final q = v.text.toLowerCase();
        return _kGotras.where((g) => g.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        if (_innerCtrl != textController) {
          _innerCtrl?.removeListener(_onInnerChanged);
          _innerCtrl = textController;
          _innerCtrl!.addListener(_onInnerChanged);
          // Seed initial value
          if (widget.controller.text.isNotEmpty) {
            textController.text = widget.controller.text;
          }
        }
        return TextField(
          controller: textController,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.family_restroom_outlined, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          onSubmitted: (_) => onSubmitted(),
        );
      },
      onSelected: (String value) {
        widget.controller.text = value;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(option, style: const TextStyle(fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _innerCtrl?.removeListener(_onInnerChanged);
    super.dispose();
  }
}
