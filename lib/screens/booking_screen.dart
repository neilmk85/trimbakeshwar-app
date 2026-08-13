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

  const BookingScreen({super.key, required this.selectedPooja});

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

  // Family booking
  final _familyGotraCtrl = TextEditingController();
  final List<TextEditingController> _familyNameCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _items = [_CartItem(poojaName: widget.selectedPooja)];
    RoomService.rooms.addListener(_onRoomsChanged);
    RoomService.isLoading.addListener(_onRoomsChanged);
    RoomService.load(force: true);
    final userEmail = AuthService.currentUser?.email ?? '';
    if (userEmail.isNotEmpty) _myEmailCtrl.text = userEmail;
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
    setState(() => _items.add(_CartItem(poojaName: _poojas.first.name)));
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
          _snack('Please select a check-in date for your stay');
          return;
        }
        if (_items[i].checkOutDate == null) {
          _snack('Please select a check-out date for your stay');
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

    setState(() => _processing = true);

    final now = DateTime.now();
    final baseOrderId = _shortOrderId(now);
    final orders = <OrderModel>[];
    final fc = _bookingFor == _BookingFor.family ? _familyNameCtrls.length : 1;
    final familyNames = _bookingFor == _BookingFor.family
        ? _familyNameCtrls.map((c) => c.text.trim()).toList()
        : null;

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final orderId = _items.length > 1 ? '${baseOrderId}_${i + 1}' : baseOrderId;
      final color = _poojas.where((p) => p.name == item.poojaName).firstOrNull?.color ?? AppColors.primary;
      orders.add(OrderModel(
        orderId: orderId,
        poojaName: item.poojaName,
        poojaDate: item.date!,
        gotra: _bookingFor == _BookingFor.family
            ? _familyGotraCtrl.text.trim()
            : item.gotraCtrl.text.trim(),
        numberOfPeople: _bookingFor == _BookingFor.family ? fc : item.numberOfPeople,
        poojaRatePerPerson: item.poojaAmount(_poojas),
        isPrivatePooja: item.isPrivatePooja,
        totalAmount: item.totalAmount(_poojas, familyCount: fc),
        checkInDate: item.wantsStay ? item.checkInDate : null,
        numberOfRooms: item.wantsStay ? item.numberOfRooms : 0,
        numberOfNights: item.wantsStay ? item.numberOfNights : 0,
        stayRatePerRoom: item.wantsStay ? item.stayRate : 0,
        selectedRoomId: item.wantsStay ? item.selectedRoom?.id : null,
        selectedRoomName: item.wantsStay ? item.selectedRoom?.name : null,
        bookedOn: now,
        poojaColor: color,
        bookedForName: _bookingFor == _BookingFor.someoneElse
            ? _nameCtrl.text.trim()
            : null,
        bookedForPhone: _bookingFor == _BookingFor.someoneElse
            ? _phoneCtrl.text.trim()
            : null,
        bookedForEmail: _bookingFor == _BookingFor.someoneElse
            ? (_emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim())
            : (_myEmailCtrl.text.trim().isEmpty ? null : _myEmailCtrl.text.trim()),
        bookedForCity: _bookingFor == _BookingFor.someoneElse
            ? (_cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim())
            : null,
        bookedForZipCode: _bookingFor == _BookingFor.someoneElse
            ? (_zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim())
            : null,
        bookedForCountry: _bookingFor == _BookingFor.someoneElse ? _country : null,
        familyNames: familyNames,
      ));
    }

    // Try to sync to server; if unreachable, still save locally
    for (final order in orders) {
      await ApiService.createBooking(order, user.phone);
    }

    // Always add to local order list so the user can see their bookings
    OrderService.ordersNotifier.value = [
      ...orders.reversed,
      ...OrderService.ordersNotifier.value,
    ];

    if (!mounted) return;
    setState(() => _processing = false);
    _showBookingToast(orders.first.orderId);
  }

  void _showBookingToast(String firstOrderId) {
    HapticFeedback.heavyImpact();

    bool dismissed = false;
    OverlayEntry? entry;

    void dismiss() {
      if (dismissed) return;
      dismissed = true;
      entry?.remove();
      // Stay on the current screen — do NOT pop
    }

    final fc = _bookingFor == _BookingFor.family ? _familyNameCtrls.length : 0;
    final familyInfo = fc > 0 ? '$fc family members' : '';
    final poojaName = _items.length == 1
        ? _items.first.poojaName
        : _items.map((e) => e.poojaName).join(', ');
    final date = _items.first.date != null ? _formatDate(_items.first.date!) : '';

    entry = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => dismiss(),
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: dismiss,
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
      appBar: AppBar(
        title: Text(
          AppL10n.s.bookingFormTitle,
          style: const TextStyle(
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
                _buildBookingForCard(),
                const SizedBox(height: 14),
                ...List.generate(
                  _items.length,
                  (i) => Column(children: [
                    _buildPoojaCard(i),
                    const SizedBox(height: 14),
                  ]),
                ),
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
          _cardHeader(Icons.person_outline, 'Booking For'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _forToggle('Myself', _BookingFor.myself)),
              const SizedBox(width: 8),
              Expanded(child: _forToggle('Someone Else', _BookingFor.someoneElse)),
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
            _textField(
                controller: _cityCtrl,
                hint: 'City (optional)',
                icon: Icons.location_city_outlined,
                caps: TextCapitalization.words),
            const SizedBox(height: 10),
            _textField(
                controller: _zipCtrl,
                hint: 'ZIP / PIN Code (optional)',
                icon: Icons.pin_drop_outlined,
                type: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
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
          // ── Family fields ──
          if (_bookingFor == _BookingFor.family) ...[
            const SizedBox(height: 14),
            _textField(
                controller: _familyGotraCtrl,
                hint: 'Family Gotra — Optional (same for all members)',
                icon: Icons.family_restroom_outlined,
                caps: TextCapitalization.words),
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
                child: Row(
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
              );
            }),
            TextButton.icon(
              onPressed: () => setState(
                  () => _familyNameCtrls.add(TextEditingController())),
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

  Widget _forToggle(String label, _BookingFor value) {
    return _ForToggleButton(
      label: label,
      selected: _bookingFor == value,
      onTap: () => setState(() => _bookingFor = value),
    );
  }

  // ── Section: Pooja Card ───────────────────────────────────────────────────────

  Widget _buildPoojaCard(int index) {
    final item = _items[index];
    final pooja =
        _poojas.where((p) => p.name == item.poojaName).firstOrNull;
    final color = pooja?.color ?? AppColors.primary;
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
              if (v != null) setState(() {
                item.poojaName = v;
              });
            },
          ),
          const SizedBox(height: 12),

          // Gotra — hidden for family (shared gotra entered above)
          if (_bookingFor != _BookingFor.family) ...[
            TextFormField(
              controller: item.gotraCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                  'Enter Gotra (Optional)', Icons.family_restroom_outlined),
            ),
            const SizedBox(height: 12),
          ],

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
                        ? AppL10n.s.dateLabel
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
            _stayCounter(
              icon: Icons.people_outline,
              label: AppL10n.s.numberOfPersons,
              value: item.numberOfPeople,
              min: 1,
              max: 20,
              onDecrement: () => setState(() => item.numberOfPeople--),
              onIncrement: () => setState(() => item.numberOfPeople++),
            ),
            const SizedBox(height: 12),
          ],

          // Private pooja toggle — always visible
          _PrivatePoojaCard(
            color: color,
            rate: pooja?.privatePoojaRate ?? 0,
            isSelected: item.isPrivatePooja,
            formatAmount: _formatAmount,
            enabled: pooja?.privatePooja == true,
            onChanged: pooja?.privatePooja == true
                ? (v) => setState(() => item.isPrivatePooja = v)
                : null,
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
                          Text('Rate per Person',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w500)),
                          Text(_formatAmount(item.poojaAmount(_poojas)),
                              style:
                                  TextStyle(fontSize: 13, color: color)),
                        ],
                      ),
                      const SizedBox(height: 4),
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

          // ── Stay section ────────────────────────────────────────────────
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Stay toggle
          Container(
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
                    if (v && _rooms.isEmpty) {
                      RoomService.load(force: true);
                    }
                    setState(() => item.wantsStay = v);
                  },
                ),
              ],
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
              // Check-in date picker
              _stayDateTile(
                icon: Icons.login_rounded,
                label: 'Check-in Date',
                value: item.checkInDate,
                color: color,
                onTap: () => _pickStayDate(item, isCheckIn: true),
              ),
              const SizedBox(height: 6),
              // Check-out date picker
              _stayDateTile(
                icon: Icons.logout_rounded,
                label: 'Check-out Date',
                value: item.checkOutDate,
                color: color,
                enabled: item.checkInDate != null,
                onTap: () => _pickStayDate(item, isCheckIn: false),
              ),
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
                      Text('${item.numberOfNights} night${item.numberOfNights == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _stayCounter(
                icon: Icons.meeting_room_outlined,
                label: 'Rooms',
                value: item.numberOfRooms,
                min: 1,
                max: item.selectedRoom!.availableCount,
                onDecrement: () => setState(() => item.numberOfRooms--),
                onIncrement: () {
                  if (item.numberOfRooms >= item.selectedRoom!.availableCount) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Only ${item.selectedRoom!.availableCount} room(s) available'),
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

  Future<void> _pickStayDate(_CartItem item, {required bool isCheckIn}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minDate = isCheckIn ? today : (item.checkInDate?.add(const Duration(days: 1)) ?? today);
    DateTime picked = isCheckIn
        ? (item.checkInDate ?? now)
        : (item.checkOutDate ?? minDate);
    if (picked.isBefore(minDate)) picked = minDate;

    await showDialog(
      context: context,
      builder: (_) => _StayDateDialog(
        title: isCheckIn ? 'Select Check-in Date' : 'Select Check-out Date',
        initial: picked,
        first: minDate,
        onConfirm: (d) {
          setState(() {
            if (isCheckIn) {
              item.checkInDate = d;
              // Reset check-out if it's before new check-in
              if (item.checkOutDate != null &&
                  !item.checkOutDate!.isAfter(d)) {
                item.checkOutDate = null;
              }
            } else {
              item.checkOutDate = d;
            }
          });
        },
      ),
    );
  }

  Widget _stayCounter({
    required IconData icon,
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700)),
        const Spacer(),
        IconButton(
          onPressed: value > min ? onDecrement : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: value > min ? AppColors.primary : AppColors.grey300,
          iconSize: 24,
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(
          width: 36,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          onPressed: value < max ? onIncrement : null,
          icon: const Icon(Icons.add_circle_outline),
          color: value < max ? AppColors.primary : AppColors.grey300,
          iconSize: 24,
          visualDensity: VisualDensity.compact,
        ),
      ],
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
      onTap: () => setState(() {
        item.selectedRoom = room;
        if (item.numberOfRooms > room.count) item.numberOfRooms = 1;
      }),
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
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
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
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _bellCtrl.dispose();
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
