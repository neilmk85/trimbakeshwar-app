import 'package:flutter/material.dart';
import '../constants/app_l10n.dart';
import '../constants/constants.dart';
import '../models/room_model.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import 'login_screen.dart';
import 'room_booking_screen.dart';

void _showLoginRequired(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              AppL10n.s.loginRequired,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyDeep),
            ),
            const SizedBox(height: 8),
            Text(
              AppL10n.s.pleaseLoginToBook,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(AppL10n.s.logIn, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppL10n.s.cancelLabel, style: const TextStyle(color: Colors.black45)),
            ),
          ],
        ),
      ),
    ),
  );
}

// Color palette assigned to rooms by index
const _palette = [
  Color(0xFF1565C0),  // primary blue
  Color(0xFF2E7D32),  // forest green
  Color(0xFF00838F),  // teal
  Color(0xFF6A1B9A),  // deep purple
  Color(0xFFE65100),  // deep orange
  Color(0xFF880E4F),  // deep maroon-rose
  Color(0xFF4527A0),  // deep indigo
  Color(0xFF00695C),  // dark teal
];

const _icons = [
  Icons.bed_rounded,
  Icons.king_bed_rounded,
  Icons.ac_unit_rounded,
  Icons.hotel_rounded,
  Icons.family_restroom_rounded,
  Icons.villa_rounded,
  Icons.weekend_rounded,
  Icons.meeting_room_rounded,
];

Color _colorFor(int index) => _palette[index % _palette.length];
IconData _iconFor(int index) => _icons[index % _icons.length];

// ── Main Screen ───────────────────────────────────────────────────────────────

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await RoomService.load(force: true);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RoomModel>>(
      valueListenable: RoomService.rooms,
      builder: (context, rooms, _) {
        return ColoredBox(
          color: const Color(0xFFF5F6FA),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroBanner(roomCount: rooms.length)),
              if (_loading && rooms.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!_loading && rooms.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            RoomService.lastError != null
                                ? AppL10n.s.couldNotLoadRooms
                                : AppL10n.s.noRoomsAvailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(AppL10n.s.retryLabel),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  // 80 = floating nav bar height (62 container + 8 top pad + 10 bottom pad)
                  padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).padding.bottom + 80 + 16),
                  sliver: _RoomGrid(rooms: rooms),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final int roomCount;
  const _HeroBanner({required this.roomCount});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      width: double.infinity,
      height: topPad + 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Building photo — crop to center (building is portrait, header is landscape)
          Image.asset(
            'assets/images/gurukrupa_niwas.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.2),
          ),

          // Dark gradient overlay — stronger at top (status bar) and bottom (text area)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.62),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Hamburger
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppL10n.s.accommodationHeading,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            AppL10n.s.roomsAndStay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(Icons.verified_rounded,
                          roomCount > 0 ? AppL10n.s.roomTypesChip(roomCount) : AppL10n.s.numberOfRoomsLabel),
                      _chip(Icons.location_on_rounded, AppL10n.s.nearTemple),
                      _chip(Icons.local_dining_rounded, AppL10n.s.sattvicMeals),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

// ── Room Grid ─────────────────────────────────────────────────────────────────

class _RoomGrid extends StatelessWidget {
  final List<RoomModel> rooms;
  const _RoomGrid({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _RoomCard(
          room: rooms[index],
          color: _colorFor(index),
          icon: _iconFor(index),
          allRooms: rooms,
          index: index,
        ),
        childCount: rooms.length,
      ),
    );
  }
}

// ── Room Card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final Color color;
  final IconData icon;
  final List<RoomModel> allRooms;
  final int index;

  const _RoomCard({
    required this.room,
    required this.color,
    required this.icon,
    required this.allRooms,
    required this.index,
  });

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            _RoomDetailScreen(rooms: allRooms, initialIndex: index),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    room.imageUrl.isNotEmpty
                        ? Image.network(
                            room.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _gradientFallback(color, icon),
                          )
                        : _gradientFallback(color, icon),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: room.type == 'AC'
                              ? AppColors.primary
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          room.type,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    // Unavailable overlay
                    if (!room.available)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black54,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(AppL10n.s.unavailableLabel,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                    // Capacity badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded,
                              size: 11, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(room.capacity,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyDeep),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${room.pricePerNight} / ${AppL10n.s.perNight}',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: color),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${room.availableCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'Available',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.grey500,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openDetail(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.remove_red_eye_rounded, size: 11, color: color),
                                    const SizedBox(width: 3),
                                    Text(AppL10n.s.viewLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: room.available
                                  ? () {
                                      if (AuthService.currentUser == null) {
                                        _showLoginRequired(context);
                                        return;
                                      }
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => RoomBookingScreen(room: room),
                                      ));
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: room.available ? AppColors.primary : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.book_online_rounded, size: 11, color: room.available ? Colors.white : Colors.grey),
                                    const SizedBox(width: 3),
                                    Text(AppL10n.s.bookLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: room.available ? Colors.white : Colors.grey)),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  static Widget _gradientFallback(Color color, IconData icon) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(icon, size: 52, color: Colors.white.withValues(alpha: 0.35)),
        ),
      );
}

// ── Room Detail Screen ────────────────────────────────────────────────────────

class _RoomDetailScreen extends StatefulWidget {
  final List<RoomModel> rooms;
  final int initialIndex;

  const _RoomDetailScreen({
    required this.rooms,
    required this.initialIndex,
  });

  @override
  State<_RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<_RoomDetailScreen> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.rooms[_current];
    final color = _colorFor(_current);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Page View — swipe between rooms
          PageView.builder(
            controller: _pageController,
            itemCount: widget.rooms.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return _RoomPage(
                room: widget.rooms[i],
                color: _colorFor(i),
                icon: _iconFor(i),
              );
            },
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  8, MediaQuery.of(context).padding.top + 4, 16, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '₹${room.pricePerNight} / ${AppL10n.s.perNight}',
                          style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_current + 1} / ${widget.rooms.length}',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          // Prev arrow
          if (_current > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 120,
              child: Center(
                child: _navBtn(Icons.chevron_left_rounded, () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }),
              ),
            ),

          // Next arrow
          if (_current < widget.rooms.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 120,
              child: Center(
                child: _navBtn(Icons.chevron_right_rounded, () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      );
}

// ── Room Full Page ────────────────────────────────────────────────────────────

class _RoomPage extends StatelessWidget {
  final RoomModel room;
  final Color color;
  final IconData icon;

  const _RoomPage({
    required this.room,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              room.imageUrl.isNotEmpty
                  ? Image.network(
                      room.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFF121212),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: room.type == 'AC'
                                    ? AppColors.primary
                                    : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(room.type,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${room.pricePerNight} / ${AppL10n.s.perNight}',
                            style: TextStyle(
                                color: color,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person_rounded,
                                  size: 13, color: Colors.white54),
                              const SizedBox(width: 3),
                              Text(room.capacity,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (room.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      room.description,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13, height: 1.65),
                    ),
                  ],
                  if (room.amenities.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      AppL10n.s.amenities,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.amenities
                          .map((a) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.4)),
                                ),
                                child: Text(a,
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Builder(builder: (ctx) => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: room.available
                          ? () {
                              if (AuthService.currentUser == null) {
                                        _showLoginRequired(ctx);
                                        return;
                              }
                              Navigator.of(ctx).push(MaterialPageRoute(
                                builder: (_) => RoomBookingScreen(room: room),
                              ));
                            }
                          : null,
                      icon: const Icon(Icons.book_online_rounded, size: 18),
                      label: Text(room.available ? AppL10n.s.bookNow : AppL10n.s.unavailableLabel,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: room.available ? AppColors.primary : Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(icon, size: 90, color: Colors.white.withValues(alpha: 0.3)),
        ),
      );
}
