import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import 'booking_detail_screen.dart';
import 'home_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String? highlightOrderId;
  const OrdersScreen({super.key, this.highlightOrderId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final phone = AuthService.currentUser?.phone;
    if (phone != null) await OrderService.loadFromServer(phone);
    // After data loads, scroll to the highlighted order
    if (widget.highlightOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
    }
  }

  void _scrollToHighlight() {
    final orders = [...OrderService.ordersNotifier.value]
      ..sort((a, b) => b.bookedOn.compareTo(a.bookedOn));
    final idx = orders.indexWhere((o) => o.orderId == widget.highlightOrderId);
    if (idx <= 0 || !_scrollCtrl.hasClients) return;
    // Each card is roughly 220px tall + 12px separator
    _scrollCtrl.animateTo(
      idx * 232.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    if (str.length <= 5) {
      return '₹${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return '₹${str.substring(0, str.length - 5)},${str.substring(str.length - 5, str.length - 3)},${str.substring(str.length - 3)}';
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    SliverAppBar _appBar() => SliverAppBar(
          floating: true,
          snap: true,
          title: Text(
            AppL10n.s.myOrders,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 3),
              ),
              (_) => false,
            ),
          ),
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
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ValueListenableBuilder<List<OrderModel>>(
          valueListenable: OrderService.ordersNotifier,
          builder: (context, orders, _) {
            if (orders.isEmpty) {
              return CustomScrollView(
                slivers: [
                  _appBar(),
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryMedium
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_outlined,
                                size: 38, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(AppL10n.s.noBookingsYet,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.facebook)),
                          const SizedBox(height: 8),
                          Text(AppL10n.s.noBookingsHint,
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.grey500)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            final sorted = [...orders]
              ..sort((a, b) => b.bookedOn.compareTo(a.bookedOn));
            return CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                _appBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(
                      order: sorted[i],
                      formatAmount: _formatAmount,
                      formatDate: _formatDate,
                      highlighted: sorted[i].orderId == widget.highlightOrderId,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  final String Function(int) formatAmount;
  final String Function(DateTime) formatDate;
  final bool highlighted;

  const _OrderCard({
    required this.order,
    required this.formatAmount,
    required this.formatDate,
    this.highlighted = false,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    if (widget.highlighted) {
      // Pulse 3 times then stay on
      _glowCtrl.repeat(reverse: true, count: 3).whenComplete(() {
        if (mounted) _glowCtrl.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final color = order.cancelled
        ? const Color.fromARGB(255, 51, 77, 203)
        : order.poojaColor;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(order: widget.order),
        ),
      ),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: widget.highlighted
                ? Border.all(
                    color: const Color(0xFFFF8F00)
                        .withValues(alpha: 0.4 + 0.6 * _glowAnim.value),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.highlighted
                    ? const Color(0xFFFF8F00)
                        .withValues(alpha: 0.15 + 0.25 * _glowAnim.value)
                    : Colors.grey.withValues(alpha: 0.2),
                blurRadius: widget.highlighted ? 16 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1D87E4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(order.isRoomOnly ? Icons.hotel_rounded : Icons.auto_awesome, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (order.isPrivatePooja) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_person_outlined,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(AppL10n.s.privatePooja,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                order.cancelled
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cancel_outlined,
                                size: 12, color: Color(0xFFC62828)),
                            const SizedBox(width: 4),
                            Text(AppL10n.s.cancelledLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC62828))),
                          ],
                        ),
                      )
                    : order.completed
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.task_alt,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(AppL10n.s.completedLabel,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(AppL10n.s.confirmedLabel,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(
                  order.isRoomOnly ? Icons.hotel_rounded : Icons.calendar_today_outlined,
                  order.isRoomOnly ? AppL10n.s.checkInDate : AppL10n.s.dateLabel,
                  order.eventDate != null ? widget.formatDate(order.eventDate!) : '—',
                  tag: order.rescheduled ? 'Rescheduled' : null,
                  tagColor: const Color(0xFF6A1B9A),
                  labelColor: Colors.black,
                  valueColor: Colors.black,
                  bold: true,
                ),
                if (!order.isRoomOnly) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.people_outline, AppL10n.s.persons,
                      '${order.numberOfPeople}'),
                  const SizedBox(height: 8),
                  _detailRow(
                      Icons.family_restroom_outlined, 'Gotra', order.gotra),
                ],
                const Divider(height: 20, color: Color(0xFFE0E0E0)),
                // Cost bifurcation
                if (!order.isRoomOnly)
                  _costRow(
                    order.isPrivatePooja ? AppL10n.s.privatePooja : AppL10n.s.pooja,
                    order.numberOfPeople > 1
                        ? '${order.numberOfPeople} × ${widget.formatAmount(order.poojaRatePerPerson)}'
                        : null,
                    widget.formatAmount(order.poojaRatePerPerson * order.numberOfPeople),
                  ),
                if (order.numberOfRooms > 0) ...[
                  const SizedBox(height: 4),
                  _costRow(
                    'Stay',
                    '${order.numberOfRooms} room${order.numberOfRooms > 1 ? 's' : ''} × '
                        '${order.numberOfNights} night${order.numberOfNights > 1 ? 's' : ''} × '
                        '${widget.formatAmount(order.stayRatePerRoom)}',
                    widget.formatAmount(order.stayRatePerRoom *
                        order.numberOfRooms *
                        order.numberOfNights),
                  ),
                ],
                const Divider(height: 16, color: Color(0xFFE0E0E0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.cancelled ? AppL10n.s.amountLabel : AppL10n.s.amountPaid,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      widget.formatAmount(order.totalAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                        decoration: order.cancelled
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${AppL10n.s.bookedOn}: ${widget.formatDate(order.bookedOn)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _costRow(String label, String? subtitle, String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey700)),
              if (subtitle != null)
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey500)),
            ],
          ),
        ),
        Text(amount,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {String? tag,
      Color? tagColor,
      Color? labelColor,
      Color? valueColor,
      bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                fontSize: 13,
                color: labelColor ?? AppColors.grey700,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor),
              overflow: TextOverflow.ellipsis),
        ),
        if (tag != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: (tagColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color:
                      (tagColor ?? AppColors.primary).withValues(alpha: 0.35)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: tagColor ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
