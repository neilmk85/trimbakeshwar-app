import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../constants/app_l10n.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'edit_profile_screen.dart';
import 'register_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.onNavigateToTab});
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final phone = AuthService.currentUser?.phone;
    if (phone != null) await OrderService.loadFromServer(phone);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, user, _) {
        if (user == null) return _GuestView(onLoginSuccess: _refresh);
        return _LoggedInView(user: user, onRefresh: _refresh, onNavigateToTab: widget.onNavigateToTab);
      },
    );
  }
}

// ── Guest (not logged in) ────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  const _GuestView({required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Column(
        children: [
          const _GuestHero(),

          // Buttons
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                        final phone = AuthService.currentUser?.phone;
                        if (phone != null) {
                          await OrderService.loadFromServer(phone);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: Text(
                        AppL10n.s.signIn,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                        final phone = AuthService.currentUser?.phone;
                        if (phone != null) {
                          await OrderService.loadFromServer(phone);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppL10n.s.createAccount,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest Hero ────────────────────────────────────────────────────────────────

class _GuestHero extends StatelessWidget {
  const _GuestHero();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _BottomArcClipper(),
      child: SizedBox(
        width: double.infinity,
        height: topPad + 260,
        child: Stack(
          children: [
            // Layer 1: deep blue gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF050B1E),
                      Color(0xFF0A1A4A),
                      Color(0xFF0D47A1),
                      Color(0xFF0A2A7A),
                      Color(0xFF061540),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Layer 2: radial blue glow at top-center
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 0.9,
                    colors: [
                      const Color(0xFF1E88E5).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Layer 3: OM watermark (faint, bottom-right)
            Positioned(
              right: -8,
              bottom: 24,
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 140,
                  color: Colors.white.withValues(alpha: 0.05),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Layer 4: content
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D2E6A),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withValues(alpha: 0.40),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: const Color(0xFF0D47A1).withValues(alpha: 0.55),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      '✦  ${AppL10n.s.myAccount}  ✦',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppL10n.s.welcomeDevotee,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Devotee badge pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppL10n.s.trimbakeshwarDevotee,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 32)
      ..quadraticBezierTo(
        size.width / 2, size.height + 22,
        size.width, size.height - 32,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_BottomArcClipper old) => false;
}

// ── Logged in ────────────────────────────────────────────────────────────────

class _LoggedInView extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;
  final ValueChanged<int>? onNavigateToTab;
  const _LoggedInView({required this.user, required this.onRefresh, this.onNavigateToTab});

  String _fmt(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return '₹$s';
    if (s.length <= 5) return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    return '₹${s.substring(0, s.length - 5)},${s.substring(s.length - 5, s.length - 3)},${s.substring(s.length - 3)}';
  }

  String _fmtDate(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Profile header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _ProfileHeader(user: user)),

            // ── Bookings ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(AppL10n.s.myBookings,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRefresh,
                      child: const Icon(Icons.refresh_rounded,
                          size: 20, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
            ),

            ValueListenableBuilder<List<OrderModel>>(
              valueListenable: OrderService.ordersNotifier,
              builder: (context, orders, _) {
                if (orders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyBookings(onNavigateToTab: onNavigateToTab),
                  );
                }
                final sorted = [...orders]
                  ..sort((a, b) => b.bookedOn.compareTo(a.bookedOn));
                final preview = sorted.take(3).toList();
                return SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),
                    ...preview.map((o) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _BookingTile(
                              order: o, fmt: _fmt, fmtDate: _fmtDate),
                        )),
                    if (sorted.length > 3)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrdersScreen()),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppL10n.s.viewAllBookings(sorted.length),
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ]),
                );
              },
            ),

            // ── Account actions ─────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              sliver: SliverToBoxAdapter(
                child: _AccountActions(user: user),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.appBarGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(user.phone,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
                if (user.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 1),
              ),
              child: Text(AppL10n.s.editLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact booking tile ──────────────────────────────────────────────────────

class _BookingTile extends StatelessWidget {
  final OrderModel order;
  final String Function(int) fmt;
  final String Function(DateTime) fmtDate;
  const _BookingTile(
      {required this.order, required this.fmt, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    final statusColor = order.cancelled
        ? const Color(0xFFC62828)
        : order.completed
            ? const Color(0xFF2E7D32)
            : AppColors.primary;
    final statusLabel = order.cancelled
        ? AppL10n.s.cancelledLabel
        : order.completed
            ? AppL10n.s.completedLabel
            : AppL10n.s.confirmedLabel;

    final title = order.isRoomOnly
        ? 'Room Stay – ${order.selectedRoomName ?? '—'}'
        : order.poojaName;
    final eventDate = order.eventDate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: order.poojaColor,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 14),
          // Icon
          Icon(
            order.isRoomOnly
                ? Icons.hotel_rounded
                : Icons.auto_awesome_rounded,
            size: 22,
            color: order.poojaColor,
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${eventDate != null ? fmtDate(eventDate) : '—'}  ·  ${fmt(order.totalAmount)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ),
          // Status chip
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty bookings state ──────────────────────────────────────────────────────

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({this.onNavigateToTab});
  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(AppL10n.s.noBookingsYet,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            Text(AppL10n.s.noBookingsHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ctaButton(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: AppL10n.s.bookPooja,
                  onTap: () => onNavigateToTab?.call(1),
                ),
                const SizedBox(width: 12),
                _ctaButton(
                  context,
                  icon: Icons.hotel_rounded,
                  label: AppL10n.s.bookRoom,
                  onTap: () => onNavigateToTab?.call(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 7),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Account actions ───────────────────────────────────────────────────────────

class _AccountActions extends StatelessWidget {
  final UserModel user;
  const _AccountActions({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _tile(
            icon: Icons.edit_outlined,
            label: AppL10n.s.editProfile,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _tile(
            icon: Icons.receipt_long_outlined,
            label: AppL10n.s.allBookings,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _tile(
            icon: Icons.logout_rounded,
            label: AppL10n.s.signOut,
            color: Colors.red,
            onTap: () => AuthService.logout().ignore(),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? const Color(0xFF1A1A2E);
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: c)),
      trailing: color == null
          ? const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.grey500)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
