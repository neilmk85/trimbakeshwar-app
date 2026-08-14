import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_l10n.dart';
import '../constants/constants.dart';
import '../models/pooja_model.dart';
import '../utils/app_images.dart';
import '../utils/app_route.dart';
import '../services/auth_service.dart';
import '../services/pooja_service.dart';
import '../widgets/app_image.dart';
import 'booking_screen.dart';
import 'login_screen.dart';

Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

final _heroImages = <String, String>{
  'Narayan Nagbali':     AppImages.narayanNagbali,
  'Kalsarpa Shanti':     AppImages.kalsarpaShanti,
  'Tripindi Shraddha':   AppImages.tripindi,
  'Rudra Abhishek':      AppImages.rudraAbhishek,
  'Mahamrityunjay Jaap': AppImages.mahamrityunjayJaap,
  'Laghu Rudra Pooja':   AppImages.laghuRudra,
  'Navgrah Shanti':      AppImages.navgrahShanti,
};

class PoojaDetailScreen extends StatefulWidget {
  final PoojaModel pooja;
  const PoojaDetailScreen({super.key, required this.pooja});

  @override
  State<PoojaDetailScreen> createState() => _PoojaDetailScreenState();
}

class _PoojaDetailScreenState extends State<PoojaDetailScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  double _appBarOpacity = 0.0;
  late PoojaModel _pooja;

  @override
  void initState() {
    super.initState();
    _pooja = widget.pooja;
    _syncFromCache();

    _scrollCtrl.addListener(() {
      final opacity = (_scrollCtrl.offset / 260.0).clamp(0.0, 1.0);
      if ((opacity - _appBarOpacity).abs() > 0.01) {
        setState(() => _appBarOpacity = opacity);
      }
    });

    // Listen for fresh API data so muhurta dates and prices update automatically
    PoojaService.poojas.addListener(_onPoojaServiceUpdate);
    PoojaService.load(force: true, silent: true);
  }

  void _syncFromCache() {
    final match = PoojaService.poojas.value
        .where((p) => p.name == widget.pooja.name && p.pricePerPerson > 0)
        .firstOrNull;
    if (match != null) _pooja = match;
  }

  void _onPoojaServiceUpdate() {
    if (!mounted) return;
    final match = PoojaService.poojas.value
        .where((p) => p.name == widget.pooja.name && p.pricePerPerson > 0)
        .firstOrNull;
    if (match != null) setState(() => _pooja = match);
  }

  @override
  void dispose() {
    PoojaService.poojas.removeListener(_onPoojaServiceUpdate);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _book(BuildContext context) {
    final pooja = _pooja;
    if (AuthService.isLoggedIn) {
      Navigator.push(context,
          fadeSlideRoute((_) => BookingScreen(selectedPooja: pooja.name)));
    } else {
      Navigator.push(context,
          fadeSlideRoute((_) => LoginScreen(
            onLoginSuccess: (_) => BookingScreen(selectedPooja: pooja.name),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pooja = _pooja;
    final color = pooja.color;
    final dark = _darken(color, 0.22);
    final heroImage = _heroImages[pooja.name];
    final hasPhoto = heroImage != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F3F8),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                SliverAppBar(
                  expandedHeight: hasPhoto ? 420.0 : 270.0,
                  pinned: true,
                  backgroundColor: hasPhoto
                      ? Color.lerp(Colors.transparent, dark, _appBarOpacity)!
                      : dark,
                  elevation: 0,
                  title: Opacity(
                    opacity: _appBarOpacity,
                    child: Text(
                      AppL10n.s.poojaName(pooja.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _HeroBanner(
                      pooja: pooja,
                      color: color,
                      dark: dark,
                      heroImage: heroImage,
                      onMuhurtaTap: () =>
                          showMuhurtaSheet(context, pooja.muhurtaDates, color),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pooja.info.isNotEmpty) ...[
                          _InfoCard(color: color, info: AppL10n.s.poojaInfo(pooja.name, pooja.info)),
                          const SizedBox(height: 14),
                        ],
                        if (pooja.thingsToBring.isNotEmpty) ...[
                          _ThingsCard(color: color, items: AppL10n.s.poojaBring(pooja.name, pooja.thingsToBring)),
                          const SizedBox(height: 14),
                        ],
                        if (pooja.beforeInstructions.isNotEmpty) ...[
                          _StepsCard(
                            color: color,
                            icon: Icons.checklist_rounded,
                            title: AppL10n.s.beforePooja,
                            subtitle: AppL10n.s.preparationLabel,
                            items: AppL10n.s.poojaBefore(pooja.name, pooja.beforeInstructions),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (pooja.afterInstructions.isNotEmpty)
                          _StepsCard(
                            color: const Color(0xFF2E7D32),
                            icon: Icons.task_alt_rounded,
                            title: AppL10n.s.afterPooja,
                            subtitle: AppL10n.s.postRitualLabel,
                            items: AppL10n.s.poojaAfter(pooja.name, pooja.afterInstructions),
                          ),
                        // ── Kalsarpa-specific sections ─────────────────────
                        if (pooja.name == 'Kalsarpa Shanti') ...[
                          const SizedBox(height: 14),
                          const _KaalSarpTypesCard(),
                          const SizedBox(height: 14),
                          const _KaalSarpRemediesCard(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                top: false,
                child: _BookButton(
                  color: color,
                  dark: dark,
                  onTap: () => _book(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final PoojaModel pooja;
  final Color color;
  final Color dark;
  final String? heroImage;
  final VoidCallback? onMuhurtaTap;
  const _HeroBanner({
    required this.pooja,
    required this.color,
    required this.dark,
    this.heroImage,
    this.onMuhurtaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (heroImage != null) return _buildPhotoHero();
    return _buildGradientHero();
  }

  Widget _buildPhotoHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(src: heroImage!, fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 0.5, 1.0],
              colors: [
                Color(0xBB000000),
                Color(0x44000000),
                Color(0x18000000),
              ],
            ),
          ),
        ),
        // Content pinned to bottom-left
        Positioned(
          left: 22, right: 22, bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppL10n.s.poojaName(pooja.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.8,
                  height: 1.2,
                  shadows: [
                    Shadow(color: Color(0xCC000000), blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (pooja.duration.isNotEmpty)
                    _HeroPill(
                      icon: Icons.schedule_rounded,
                      label: AppL10n.s.poojaDuration(pooja.duration),
                    ),
                  if (pooja.pricePerPerson > 0)
                    _HeroPill(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Rs ${pooja.pricePerPerson}/-',
                    ),
                  GestureDetector(
                    onTap: onMuhurtaTap,
                    child: _HeroPill(
                      icon: Icons.calendar_month_rounded,
                      label: AppL10n.s.muhurtaLabel2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dark, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: -30,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 80, right: 40,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 56, 22, 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pooja.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.8,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (pooja.duration.isNotEmpty)
                        _HeroPill(
                          icon: Icons.schedule_rounded,
                          label: AppL10n.s.poojaDuration(pooja.duration),
                        ),
                      if (pooja.pricePerPerson > 0)
                        _HeroPill(
                          icon: Icons.currency_rupee_rounded,
                          label: 'Rs ${pooja.pricePerPerson}/-',
                        ),
                      GestureDetector(
                        onTap: onMuhurtaTap,
                        child: const _HeroPill(
                          icon: Icons.calendar_month_rounded,
                          label: 'Muhurta',
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
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Color color;
  final String info;
  const _InfoCard({required this.color, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              color: color.withValues(alpha: 0.07),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_stories_rounded, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(AppL10n.s.aboutPooja,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Text(
                info,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF555566),
                  height: 1.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Things to Bring Card ──────────────────────────────────────────────────────

class _ThingsCard extends StatelessWidget {
  final Color color;
  final List<String> items;
  const _ThingsCard({required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              color: color.withValues(alpha: 0.07),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppL10n.s.thingsToBring,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(AppL10n.s.itemsCount(items.length),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.check_rounded,
                              size: 15, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(e.value,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF444455),
                                    height: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Steps Card ────────────────────────────────────────────────────────────────

class _StepsCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> items;

  const _StepsCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              color: color.withValues(alpha: 0.07),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              color: color.withValues(alpha: 0.65))),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final step = e.key + 1;
                  final isLast = e.key == items.length - 1;
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('$step',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: color)),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 1.5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  color: color.withValues(alpha: 0.18),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: isLast ? 0 : 16, top: 4),
                            child: Text(e.value,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF444455),
                                    height: 1.55)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Button ───────────────────────────────────────────────────────────────

class _BookButton extends StatelessWidget {
  final Color color;
  final Color dark;
  final VoidCallback onTap;
  const _BookButton({required this.color, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [dark, color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(AppL10n.s.bookNow,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Muhurta Calendar Bottom Sheet ─────────────────────────────────────────────

void showMuhurtaSheet(BuildContext context, List<DateTime> muhurtaDates, Color color) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MuhurtaCalendarSheet(
        muhurtaDates: muhurtaDates, color: AppColors.primary),
  );
}

class MuhurtaCalendarSheet extends StatefulWidget {
  final List<DateTime> muhurtaDates;
  final Color color;

  const MuhurtaCalendarSheet({
    super.key,
    required this.muhurtaDates,
    required this.color,
  });

  @override
  State<MuhurtaCalendarSheet> createState() => _MuhurtaCalendarSheetState();
}

class _MuhurtaCalendarSheetState extends State<MuhurtaCalendarSheet> {
  late DateTime _focusedMonth;

  List<String> get _monthNames => AppL10n.s.monthNames;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = widget.muhurtaDates
        .where((d) => !DateTime(d.year, d.month, d.day).isBefore(today))
        .toList()
      ..sort();
    _focusedMonth = upcoming.isNotEmpty
        ? DateTime(upcoming.first.year, upcoming.first.month)
        : DateTime(now.year, now.month);
  }

  bool _isMuhurta(DateTime day) => widget.muhurtaDates.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.muhurtaDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.calendar_month_rounded,
                size: 48, color: widget.color.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              AppL10n.s.muhurtaDates,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppL10n.s.noMuhurta,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.grey700, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sun=0
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text(
                AppL10n.s.muhurtaDates,
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
                onPressed: () => setState(() => _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
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
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Day-of-week headers
          Row(
            children: AppL10n.s.weekDayLetters
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
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
              final isMuhurta = _isMuhurta(day);
              final isToday = day == today;
              return Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isMuhurta
                        ? Colors.orange.withValues(alpha: 0.18)
                        : null,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: widget.color, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isMuhurta
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isMuhurta ? Colors.orange.shade800 : AppColors.grey700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
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
                  width: 14,
                  height: 14,
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

// ── Kaal Sarp Yog Types ───────────────────────────────────────────────────────

class _KaalSarpTypesCard extends StatelessWidget {
  const _KaalSarpTypesCard();

  static const _teal = Color(0xFF00838F);

  List<({String name, String houses, String effect})> get _types => [
    (name: 'Anant Kaal Sarp Yog',      houses: AppL10n.s.housesAnant,      effect: AppL10n.s.effectAnant),
    (name: 'Kulik Kaal Sarp Yog',       houses: AppL10n.s.housesKulik,      effect: AppL10n.s.effectKulik),
    (name: 'Vasuki Kaal Sarp Yog',      houses: AppL10n.s.housesVasuki,     effect: AppL10n.s.effectVasuki),
    (name: 'Shankhpal Kaal Sarp Yog',   houses: AppL10n.s.housesShankhpal,  effect: AppL10n.s.effectShankhpal),
    (name: 'Kaliya Kaal Sarp Yog',      houses: AppL10n.s.housesKaliya,     effect: AppL10n.s.effectKaliya),
    (name: 'Mahapadma Kaal Sarp Yog',   houses: AppL10n.s.housesMahapadma,  effect: AppL10n.s.effectMahapadma),
    (name: 'Takshak Kaal Sarp Yog',     houses: AppL10n.s.housesTakshak,    effect: AppL10n.s.effectTakshak),
    (name: 'Karkotak Kaal Sarp Yog',    houses: AppL10n.s.housesKarkotak,   effect: AppL10n.s.effectKarkotak),
    (name: 'Shankhachud Kaal Sarp Yog', houses: AppL10n.s.housesShankhachud,effect: AppL10n.s.effectShankhachud),
    (name: 'Ghatak Kaal Sarp Yog',      houses: AppL10n.s.housesGhatak,     effect: AppL10n.s.effectGhatak),
    (name: 'Vishdhar Kaal Sarp Yog',    houses: AppL10n.s.housesVishdhar,   effect: AppL10n.s.effectVishdhar),
    (name: 'Sheshnag Kaal Sarp Yog',    houses: AppL10n.s.housesSheshnag,   effect: AppL10n.s.effectSheshnag),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_teal, const Color(0xFF00ACC1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🐍', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.s.kaalSarpTypesTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppL10n.s.kaalSarpTypesSubtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Type list
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (int i = 0; i < _types.length; i++) ...[
                  _TypeTile(index: i + 1, type: _types[i]),
                  if (i < _types.length - 1)
                    Divider(height: 1, color: _teal.withValues(alpha: 0.1)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final int index;
  final ({String name, String houses, String effect}) type;
  const _TypeTile({required this.index, required this.type});

  static const _teal = Color(0xFF00838F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                color: _teal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.houses,
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.effect,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                    height: 1.5,
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

// ── Kaal Sarp Remedies & Mantras ─────────────────────────────────────────────

class _KaalSarpRemediesCard extends StatelessWidget {
  const _KaalSarpRemediesCard();

  static const _purple = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_purple, const Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.s.remediesMantrasTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppL10n.s.chant1008Subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main remedy — Kalsarpa Shanti at Trimbakeshwar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00838F).withValues(alpha: 0.07),
                        const Color(0xFF00838F).withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF00838F).withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🛕', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            AppL10n.s.primaryRemedyLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00838F),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppL10n.s.kalsarpaTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppL10n.s.kalsarpaDesc,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF444444),
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppL10n.s.kalsarpaBenefitsTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final benefit in AppL10n.s.kalsarpaBenefits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00838F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sarpa Mantra
                _MantraBlock(
                  title: AppL10n.s.sarpaMantraLabel,
                  sanskrit: 'अनन्तध्यान महाकायन नानामणि विराजितन् |\n'
                      'आवाहयामहम् सर्पान् फणसप्तक मण्डितन् ||',
                  transliteration: 'Anantadhyan Mahakayan Nanamani Virajitan |\n'
                      'Avahayamaham Sarpan Phanasaptaka Manditan ||',
                  color: _purple,
                ),
                const SizedBox(height: 14),

                // Kaal Mantra
                _MantraBlock(
                  title: AppL10n.s.kaalMantraLabel,
                  sanskrit: 'अनाकारम् अनन्ताख्यम् वर्तमानम् दिने दिने |\n'
                      'कालकाष्ठादि रूपेण कालम् आवाहयाम्यहम् ||',
                  transliteration: 'Anakaram Anantakhyam Vartamanam Dine Dine |\n'
                      'Kalakashtadi Rupena Kalam Avahayamyaham ||',
                  color: _purple,
                ),
                const SizedBox(height: 16),

                // Chanting count note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _purple.withValues(alpha: 0.08),
                        const Color(0xFF9C27B0).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.loop_rounded, color: _purple, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AppL10n.s.chantEachMantra,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppL10n.s.timesLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppL10n.s.dailyLabel,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
                      ),
                    ],
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

class _MantraBlock extends StatelessWidget {
  final String title;
  final String sanskrit;
  final String transliteration;
  final Color color;

  const _MantraBlock({
    required this.title,
    required this.sanskrit,
    required this.transliteration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(Icons.spa_rounded, color: color, size: 15),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Sanskrit
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              sanskrit,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.8,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Divider
          Divider(height: 1, indent: 14, endIndent: 14,
              color: color.withValues(alpha: 0.15)),
          // Transliteration
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Text(
              transliteration,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
