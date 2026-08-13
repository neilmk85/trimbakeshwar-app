import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';

class BookingDetailScreen extends StatelessWidget {
  final OrderModel order;
  const BookingDetailScreen({super.key, required this.order});

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final date = _formatDate(dt);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date, $h:$m $ampm';
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    if (str.length <= 5) {
      return '₹${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return '₹${str.substring(0, str.length - 5)},${str.substring(str.length - 5, str.length - 3)},${str.substring(str.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final accentColor = order.cancelled
        ? const Color(0xFFC62828)
        : order.poojaColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(AppL10n.s.myOrders),
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
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Compact identity card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: accentColor, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.isRoomOnly
                              ? (order.selectedRoomName?.isNotEmpty == true
                                  ? 'Room Stay – ${order.selectedRoomName}'
                                  : 'Room Booking')
                              : order.poojaName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Private chip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (order.isPrivatePooja) ...[
                        _Chip(
                          label: AppL10n.s.privateLabel,
                          icon: Icons.lock_person_outlined,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── All detail sections ────────────────────────────────────────
                  // 1 — Booking Reference
                  _Section(title: AppL10n.s.orderId, children: [
                    _DetailRow(label: AppL10n.s.orderId, value: order.orderId,
                        copyable: true),
                    if ((order.razorpayOrderId ?? '').isNotEmpty)
                      _DetailRow(
                          label: 'Razorpay Order',
                          value: order.razorpayOrderId!,
                          copyable: true),
                    if ((order.paymentId ?? '').isNotEmpty)
                      _DetailRow(
                          label: 'Payment ID',
                          value: order.paymentId!,
                          copyable: true),
                    _DetailRow(
                        label: AppL10n.s.bookedOn,
                        value: _formatDateTime(order.bookedOn)),
                  ]),

                  // 2 — Pooja / Stay Details
                  if (!order.isRoomOnly)
                    _Section(title: AppL10n.s.poojaDetails, children: [
                      _DetailRow(
                          label: AppL10n.s.pooja, value: order.poojaName),
                      if (order.poojaDate != null)
                        _DetailRow(
                            label: AppL10n.s.dateLabel,
                            value: _formatDate(order.poojaDate!)),
                      _DetailRow(
                          label: AppL10n.s.typeLabel,
                          value: order.isPrivatePooja
                              ? AppL10n.s.privatePooja
                              : AppL10n.s.publicPooja),
                      if (order.gotra.isNotEmpty)
                        _DetailRow(label: 'Gotra', value: order.gotra),
                    ]),

                  if (order.isRoomOnly)
                    _Section(title: AppL10n.s.stayDetails, children: [
                      if (order.selectedRoomName?.isNotEmpty == true)
                        _DetailRow(
                            label: AppL10n.s.bookRoom,
                            value: order.selectedRoomName!),
                      if (order.checkInDate != null)
                        _DetailRow(
                            label: AppL10n.s.checkInDate,
                            value: _formatDate(order.checkInDate!)),
                      _DetailRow(
                          label: AppL10n.s.numberOfRoomsLabel,
                          value: '${order.numberOfRooms}'),
                      _DetailRow(
                          label: AppL10n.s.numberOfNightsLabel,
                          value: '${order.numberOfNights}'),
                    ]),

                  // 3 — People
                  _Section(title: AppL10n.s.persons, children: [
                    _DetailRow(
                        label: AppL10n.s.numberOfPersons,
                        value: '${order.numberOfPeople}'),
                    if (order.familyNames != null &&
                        order.familyNames!.isNotEmpty)
                      _DetailRow(
                          label: 'Family Members',
                          value: order.familyNames!.join(', ')),
                  ]),

                  // 4 — Stay add-on (if pooja + stay)
                  if (!order.isRoomOnly && order.numberOfRooms > 0)
                    _Section(title: AppL10n.s.accommodation, children: [
                      if (order.selectedRoomName?.isNotEmpty == true)
                        _DetailRow(
                            label: AppL10n.s.bookRoom,
                            value: order.selectedRoomName!),
                      _DetailRow(
                          label: AppL10n.s.numberOfRoomsLabel,
                          value: '${order.numberOfRooms}'),
                      _DetailRow(
                          label: AppL10n.s.numberOfNightsLabel,
                          value: '${order.numberOfNights}'),
                      if (order.stayRatePerRoom > 0)
                        _DetailRow(
                            label: AppL10n.s.ratePerRoom,
                            value: _formatAmount(order.stayRatePerRoom)),
                    ]),

                  // 5 — Cost Breakdown
                  _Section(title: AppL10n.s.paymentDetails, children: [
                    if (!order.isRoomOnly && order.poojaRatePerPerson > 0)
                      _DetailRow(
                          label: order.isPrivatePooja
                              ? AppL10n.s.privatePooja
                              : AppL10n.s.pooja,
                          value: order.numberOfPeople > 1
                              ? '${_formatAmount(order.poojaRatePerPerson)} × ${order.numberOfPeople} = ${_formatAmount(order.poojaRatePerPerson * order.numberOfPeople)}'
                              : _formatAmount(order.poojaRatePerPerson)),
                    if (order.numberOfRooms > 0 && order.stayRatePerRoom > 0)
                      _DetailRow(
                          label: 'Stay Cost',
                          value:
                              '${_formatAmount(order.stayRatePerRoom)} × ${order.numberOfRooms} room${order.numberOfRooms > 1 ? 's' : ''} × ${order.numberOfNights} night${order.numberOfNights > 1 ? 's' : ''} = ${_formatAmount(order.stayRatePerRoom * order.numberOfRooms * order.numberOfNights)}'),
                    _AmountRow(
                        label: order.cancelled
                            ? AppL10n.s.amountLabel
                            : AppL10n.s.amountPaid,
                        value: _formatAmount(order.totalAmount),
                        cancelled: order.cancelled,
                        color: accentColor),
                  ]),

                  // 6 — Booked By (logged-in user)
                  _Section(title: AppL10n.s.bookedBy, children: [
                    _DetailRow(
                        label: 'Name',
                        value: order.userName ??
                            user?.fullName ??
                            '—'),
                    _DetailRow(
                        label: 'Phone',
                        value: order.userPhone ??
                            user?.phone ??
                            '—'),
                    if ((user?.email ?? '').isNotEmpty)
                      _DetailRow(
                          label: 'Email',
                          value: user!.email),
                    if ((user?.city ?? '').isNotEmpty)
                      _DetailRow(label: 'City', value: user!.city),
                    if ((user?.pinCode ?? '').isNotEmpty)
                      _DetailRow(
                          label: 'PIN Code', value: user!.pinCode),
                    if ((user?.country ?? '').isNotEmpty)
                      _DetailRow(
                          label: 'Country', value: user!.country),
                  ]),

                  // 7 — Booked For (someone else)
                  if (order.bookedForName?.isNotEmpty == true)
                    _Section(title: AppL10n.s.bookedFor, children: [
                      _DetailRow(
                          label: 'Name', value: order.bookedForName!),
                      if (order.bookedForPhone?.isNotEmpty == true)
                        _DetailRow(
                            label: 'Phone',
                            value: order.bookedForPhone!),
                      if (order.bookedForEmail?.isNotEmpty == true)
                        _DetailRow(
                            label: 'Email',
                            value: order.bookedForEmail!),
                      if (order.bookedForCity?.isNotEmpty == true)
                        _DetailRow(
                            label: 'City',
                            value: order.bookedForCity!),
                      if (order.bookedForZipCode?.isNotEmpty == true)
                        _DetailRow(
                            label: 'ZIP / PIN',
                            value: order.bookedForZipCode!),
                      if (order.bookedForCountry?.isNotEmpty == true)
                        _DetailRow(
                            label: 'Country',
                            value: order.bookedForCountry!),
                    ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Small status chip ─────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Reusable section widget ───────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Colors.grey.withValues(alpha: 0.15)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row for a label + value pair ─────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_rounded,
                    size: 15, color: Color(0xFF9CA3AF)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Booking status timeline ───────────────────────────────────────────────────


// ── Bold total row ────────────────────────────────────────────────────────────

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool cancelled;
  final Color color;

  const _AmountRow({
    required this.label,
    required this.value,
    required this.cancelled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
              decoration:
                  cancelled ? TextDecoration.lineThrough : null,
              decorationColor: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
