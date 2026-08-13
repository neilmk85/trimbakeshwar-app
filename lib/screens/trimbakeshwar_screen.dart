import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/panchang_widget.dart';
import 'package:flutter/services.dart';
import '../constants/app_l10n.dart';
import '../constants/app_strings.dart';
import '../constants/constants.dart';
import '../utils/url_helper.dart';
import '../models/pooja_model.dart';
import '../services/pooja_service.dart';
import '../utils/app_images.dart';
import '../utils/app_route.dart';
import '../widgets/app_image.dart';
import 'pooja_detail_screen.dart';
import 'pooja_screen.dart';
import 'kumbha_mela_screen.dart';
import 'nearby_attractions_screen.dart';
import 'darshan_screen.dart';

class TrimbakeshwarScreen extends StatefulWidget {
  const TrimbakeshwarScreen({super.key, this.onNavigateToPooja});
  final VoidCallback? onNavigateToPooja;

  @override
  State<TrimbakeshwarScreen> createState() => _TrimbakeshwarScreenState();
}

class _TrimbakeshwarScreenState extends State<TrimbakeshwarScreen> {
  final _scroll = ScrollController();
  bool _titleVisible = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scroll.offset > 300;
    if (show != _titleVisible) setState(() => _titleVisible = show);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _titleVisible
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          ColoredBox(
            color: const Color(0xFFF5F6FA),
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  _HeroSection(onNavigateToPooja: widget.onNavigateToPooja),
                  _StatsStrip(),
                  const SizedBox(height: 20),
                  _BookPoojaSection(onTap: widget.onNavigateToPooja),
                  const SizedBox(height: 20),
                  const _AboutSection(),
                  const SizedBox(height: 22),
                  const _QuickActions(),
                  const SizedBox(height: 22),
                  const _SacredLingaSection(),
                  const SizedBox(height: 22),
                  const _TimingsSection(),
                  const SizedBox(height: 22),
                  const _HistorySection(),
                  const SizedBox(height: 22),
                  const _FestivalsSection(),
                  const SizedBox(height: 22),
                  const _PoojasSummarySection(),
                  const SizedBox(height: 22),
                  const _SacredSitesSection(),
                  const SizedBox(height: 22),
                  const _HowToReachSection(),
                  const SizedBox(height: 22),
                  const _VisitorGuidelinesSection(),
                  const SizedBox(height: 22),
                  const _GurujiContactSection(),
                  const SizedBox(height: 22),
                  const PanchangWidget(),
                  const SafeArea(top: false, child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
          // Sticky title bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            top: _titleVisible ? 0 : -(topPad + kToolbarHeight),
            left: 0,
            right: 0,
            child: Container(
              height: topPad + kToolbarHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.appBarGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: topPad),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded,
                            color: Colors.white, size: 24),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppL10n.s.trimbakeshwar,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
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

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _sectionHeading(String title, [IconData? icon]) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryMedium],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primaryDark),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

BoxDecoration _card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatefulWidget {
  const _HeroSection({this.onNavigateToPooja});
  final VoidCallback? onNavigateToPooja;

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _SlideData {
  final String image;
  final String title;
  final String subtitle;
  final List<(IconData, String)> badges;
  final String? localCenteredAsset;
  const _SlideData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badges,
    this.localCenteredAsset,
  });
}

class _HeroSectionState extends State<_HeroSection> {
  static List<_SlideData> _getSlides() => [
    _SlideData(
      image: AppImages.narayanNagbali,
      title: AppL10n.s.heroTitle('Book Pooja'),
      subtitle: AppL10n.s.heroSubtitle('SACRED POOJA VIDHI'),
      badges: [
        (Icons.auto_awesome_rounded, AppL10n.s.heroBadge('Only place in India')),
        (Icons.self_improvement_rounded, AppL10n.s.heroBadge('Ancestral Liberation')),
        (Icons.temple_hindu_rounded, AppL10n.s.heroBadge('3-Day Ritual')),
      ],
    ),
    _SlideData(
      image: AppImages.trimbakeshwarTemple,
      title: AppL10n.s.heroTitle('Trimbakeshwar'),
      subtitle: AppL10n.s.heroSubtitle('JYOTIRLINGA MANDIR'),
      badges: [
        (Icons.location_on_rounded, AppL10n.s.heroBadge('Trimbak, Nashik')),
        (Icons.auto_awesome_rounded, AppL10n.s.heroBadge('12th Jyotirlinga')),
        (Icons.water_drop_rounded, AppL10n.s.heroBadge('Origin of Godavari')),
      ],
    ),
    _SlideData(
      image: AppImages.kumbhaMela,
      title: AppL10n.s.heroTitle('Kumbha Mela 2027'),
      subtitle: AppL10n.s.heroSubtitle('NASHIK · TRIMBAKESHWAR'),
      badges: [
        (Icons.calendar_month_rounded, AppL10n.s.heroBadge('July – Sept 2027')),
        (Icons.groups_rounded, AppL10n.s.heroBadge('7.5 Cr+ Pilgrims')),
        (Icons.water_drop_rounded, AppL10n.s.heroBadge('Shahi Snan')),
      ],
    ),
    _SlideData(
      image: AppImages.brahmagiriParvat,
      title: AppL10n.s.heroTitle('Brahmagiri'),
      subtitle: AppL10n.s.heroSubtitle('SACRED MOUNTAIN'),
      badges: [
        (Icons.terrain_rounded, AppL10n.s.heroBadge('4248 ft Altitude')),
        (Icons.water_drop_rounded, AppL10n.s.heroBadge('Godavari Origin')),
        (Icons.directions_walk_rounded, AppL10n.s.heroBadge('Trek to Summit')),
      ],
    ),
    _SlideData(
      image: AppImages.gangaDwar,
      title: AppL10n.s.heroTitle('Ganga Dwar'),
      subtitle: AppL10n.s.heroSubtitle('GATEWAY OF GODAVARI'),
      badges: [
        (Icons.waves_rounded, AppL10n.s.heroBadge('Sacred Ghat')),
        (Icons.temple_hindu_rounded, AppL10n.s.heroBadge('Ritual Bathing')),
        (Icons.star_rounded, AppL10n.s.heroBadge('Pilgrimage Site')),
      ],
    ),
    _SlideData(
      image: AppImages.kushawartaKunda,
      title: AppL10n.s.heroTitle('Kushavarta'),
      subtitle: AppL10n.s.heroSubtitle('SACRED TIRTHA KUND'),
      badges: [
        (Icons.water_rounded, AppL10n.s.heroBadge('Holy Tirtha')),
        (Icons.self_improvement_rounded, AppL10n.s.heroBadge('Ancestral Rituals')),
        (Icons.place_rounded, AppL10n.s.heroBadge('Heart of Trimbak')),
      ],
    ),
  ];

  final PageController _ctrl = PageController();
  int _current = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_current + 1) % 6;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _getSlides();
    final slide = slides[_current];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -200) {
          final next = (_current + 1) % 6;
          _ctrl.animateToPage(next,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut);
        } else if (v > 200) {
          final prev = (_current - 1 + 6) % 6;
          _ctrl.animateToPage(prev,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut);
        }
      },
      child: Stack(
      children: [
        // Carousel images
        SizedBox(
            width: double.infinity,
            height: 360,
            child: PageView.builder(
              controller: _ctrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: slides.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  switch (i) {
                    case 0:
                      widget.onNavigateToPooja?.call();
                      return;
                    case 1:
                      Navigator.push(ctx, fadeSlideRoute((_) => const DarshanScreen()));
                    case 2:
                      Navigator.push(ctx, fadeSlideRoute((_) => const KumbhaMelaScreen()));
                    case 3:
                      NearbyAttractionsScreen.openAttraction(ctx, 'Brahmagiri Mountain');
                    case 4:
                      NearbyAttractionsScreen.openAttraction(ctx, 'Gangadwar');
                    case 5:
                      NearbyAttractionsScreen.openAttraction(ctx, 'Kushavarta Kund');
                  }
                },
                child: AppImage(
                        src: slides[i].image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        // Gradient overlay
        IgnorePointer(
          child: Container(
            width: double.infinity,
            height: 360,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xEE000000),
                  Color(0x77000000),
                  Color(0x11000000),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        // Menu button
        Positioned(
          top: 0, left: 0,
          child: SafeArea(
            child: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: Colors.white, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
        ),
        // Title, subtitle, CTA and dot indicators
        Positioned(
          bottom: 22, left: 0, right: 0,
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  slide.title,
                  key: ValueKey('title_$_current'),
                  style: const TextStyle(
                    fontFamily: 'Samarkan',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  slide.subtitle,
                  key: ValueKey('sub_$_current'),
                  style: const TextStyle(
                    fontFamily: 'Samarkan',
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _current == 2
                    ? GestureDetector(
                        key: const ValueKey('kumbha_cta'),
                        onTap: () => Navigator.push(
                          context,
                          fadeSlideRoute((_) => const KumbhaMelaScreen()),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6F00),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppL10n.s.exploreKumbhaMela,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no_cta')),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _badge(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
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
                    fontSize: 10.5, color: Colors.white70, letterSpacing: 0.3)),
          ],
        ),
      );
}

// ── Stats Strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat('12th', AppL10n.s.statJyotirlinga),
            _div(),
            _stat('1755 CE', AppL10n.s.statRebuilt),
            _div(),
            _stat('28 km', AppL10n.s.statFromNashik),
            _div(),
            _stat('2969 ft', AppL10n.s.statAltitude),
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(v,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(l,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.grey700, letterSpacing: 0.3)),
        ],
      );

  Widget _div() => Container(width: 1, height: 30, color: Colors.grey.shade200);
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Darshan Timings card
          Expanded(
            child: _ActionCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6F00), Color(0xFFBF360C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFFE65100),
              icon: Icons.access_time_rounded,
              label: AppL10n.s.darshanTimings,
              sublabel: AppL10n.s.hoursQueueGuide,
              onTap: () => Navigator.push(
                context,
                fadeSlideRoute((_) => const DarshanScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Kumbha Mela card
          Expanded(
            child: _ActionCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB347), Color(0xFFFFE066)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFFFFB347),
              icon: null,
              iconWidget: const Text('🔱',
                  style: TextStyle(fontSize: 20, height: 1)),
              label: AppL10n.s.sinhastha2027,
              sublabel: AppL10n.s.kumbhaMelaLabel,
              textColor: const Color(0xFF5D2E00),
              onTap: () => Navigator.push(
                context,
                fadeSlideRoute((_) => const KumbhaMelaScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final LinearGradient gradient;
  final Color shadowColor;
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final Color textColor;

  const _ActionCard({
    required this.gradient,
    required this.shadowColor,
    this.icon,
    this.iconWidget,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
              child: Row(
                children: [
                  iconWidget ?? Icon(icon!, color: textColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sublabel,
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.75),
                              fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── About ─────────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(AppL10n.s.aboutTrimbakeshwarHeading),
          const SizedBox(height: 16),
          Text(
            AppL10n.s.aboutBodyText,
            style: const TextStyle(fontSize: 14, color: AppColors.grey700, height: 1.75),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 18),
          _tile(Icons.temple_hindu_rounded, AppL10n.s.tileLabel('Deity'),
              AppL10n.s.tileValue('Lord Shiva — Trimbakeshwar Jyotirlinga')),
          _divLine(),
          _tile(Icons.place_rounded, AppL10n.s.tileLabel('Location'),
              AppL10n.s.tileValue('Trimbak, Nashik District, Maharashtra — 422212')),
          _divLine(),
          _tile(Icons.water_drop_rounded, AppL10n.s.tileLabel('Sacred River'),
              AppL10n.s.tileValue('Godavari originates at Brahmagiri, 3 km away')),
          _divLine(),
          _tile(Icons.groups_rounded, AppL10n.s.tileLabel('Devotees'),
              AppL10n.s.tileValue('Over 10 lakh pilgrims visit annually')),
          _divLine(),
          _tile(Icons.language_rounded, AppL10n.s.tileLabel('Managed by'),
              AppL10n.s.tileValue('Shri Trimbakeshwar Devasthan Trust, Nashik')),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey700,
                    letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      );

  Widget _divLine() =>
      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100);
}

// ── Sacred Linga ──────────────────────────────────────────────────────────────

class _SacredLingaSection extends StatelessWidget {
  const _SacredLingaSection();

  static const _facts = [
    (
      Icons.diamond_rounded,
      'Triple-Faced Linga',
      'The ONLY Jyotirlinga in the world with three faces (Mukha Lingas) — Brahma, Vishnu & Rudra — in a single stone, embodying the complete Hindu Trinity.',
      Color(0xFF6A1B9A),
    ),
    (
      Icons.auto_awesome_rounded,
      'Swayambhu — Self-Manifested',
      'The linga was not carved by human hands. It manifested naturally from the earth, making it one of the most divinely sanctioned sacred objects in Hinduism.',
      Color(0xFFE65100),
    ),
    (
      Icons.workspace_premium_rounded,
      'Golden Crown (Navaratna)',
      'The linga is adorned with a golden crown studded with the nine sacred gems (Navaratnas). The crown is revealed only during special darshan and major festivals.',
      Color(0xFFFF8F00),
    ),
    (
      Icons.water_rounded,
      'Linga in a Sacred Kund',
      'The linga sits within a natural rock pit filled with water. Devotees view it from above — a humbling and unique experience found nowhere else among the 12 Jyotirlingas.',
      Color(0xFF1565C0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.sacredJyotirlinga, Icons.brightness_5_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _facts
                .map((f) => _BorderCard(
                    icon: f.$1,
                    title: AppL10n.s.sacredFactTitle(f.$2),
                    body: AppL10n.s.sacredFactBody(f.$3),
                    color: f.$4))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _BorderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _BorderCard(
      {required this.icon,
      required this.title,
      required this.body,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.grey700, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Temple Timings ────────────────────────────────────────────────────────────

class _TimingsSection extends StatelessWidget {
  const _TimingsSection();

  static const _schedule = [
    (
      'Temple Opens',
      'Daily',
      '5:30 AM',
      Color(0xFFFF8F00),
      Icons.brightness_5_rounded
    ),
    (
      'Brahma Puja',
      'Morning Puja',
      '7:00 – 8:30 AM',
      Color(0xFF6A1B9A),
      Icons.local_fire_department_rounded
    ),
    (
      'Mahadev Puja',
      'Midday Puja',
      '10:45 AM – 12:30 PM',
      Color(0xFF2E7D32),
      Icons.wb_sunny_rounded
    ),
    (
      'Vishnu Puja & Aarti',
      'Evening Puja',
      '7:00 – 8:30 PM',
      Color(0xFF1565C0),
      Icons.wb_twilight_rounded
    ),
    (
      'Temple Closes',
      'Daily',
      '9:00 PM',
      Color(0xFF37474F),
      Icons.nightlight_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.templeTimingsHeading, Icons.access_time_rounded),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: _card(),
          child: Column(
            children: List.generate(_schedule.length, (i) {
              final s = _schedule[i];
              final isLast = i == _schedule.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppL10n.s.timingSubtitle(s.$2),
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.grey700)),
                              const SizedBox(height: 1),
                              Text(AppL10n.s.timingName(s.$1),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87)),
                            ],
                          ),
                        ),
                        Text(s.$3,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF424242))),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 74,
                        endIndent: 16,
                        color: Colors.grey.shade100),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        _warnNote(AppL10n.s.timingsNote),
      ],
    );
  }
}

// ── History ───────────────────────────────────────────────────────────────────

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(AppL10n.s.historyHeading, Icons.architecture_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _tl(
                    AppL10n.s.historyTitle('Vedic Age — Ancient Origins'),
                    AppL10n.s.historyBody('The Trimbakeshwar site has been venerated since Vedic times. It is listed among the 12 Jyotirlingas in the Shiva Purana, Brahmanda Purana, and Padma Purana — the holiest pillars of Shiva\'s cosmic light on Earth.'),
                    Icons.history_edu_rounded,
                    const Color(0xFF6A1B9A)),
                _tl(
                    AppL10n.s.historyTitle('Medieval Period'),
                    AppL10n.s.historyBody('The Yadava kings of Devagiri (12th–13th century CE) were major patrons of this temple. Hemadpanthi stone inscriptions from this era still survive in the complex, attesting to centuries of royal devotion.'),
                    Icons.castle_rounded,
                    const Color(0xFF00695C)),
                _tl(
                    AppL10n.s.historyTitle('Peshwa Reconstruction (1755–1786)'),
                    AppL10n.s.historyBody('The current temple was commissioned by Peshwa Balaji Baji Rao (Nana Saheb) and completed under Vishwasrao Peshwa. Built entirely in black basalt stone in the Nagara style, it is a masterpiece of Hemadpanthi architecture.'),
                    Icons.domain_rounded,
                    const Color(0xFFE65100)),
                _tl(
                    AppL10n.s.historyTitle('Temple Structure'),
                    AppL10n.s.historyBody('• Towering Shikhara (spire) rising 29 metres\n• Wide Sabha Mandap (assembly hall) with carved pillars\n• Garbhagriha (inner sanctum) housing the Jyotirlinga\n• Nandi Mandap — shrine of Shiva\'s sacred bull\n• Courtyard with smaller shrines all around'),
                    Icons.account_balance_rounded,
                    const Color(0xFF1565C0),
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tl(String title, String body, IconData icon, Color color,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Icon(icon, size: 22, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(1)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 5),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey700,
                          height: 1.65)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Festivals ─────────────────────────────────────────────────────────────────

class _FestivalsSection extends StatelessWidget {
  const _FestivalsSection();

  static const _data = [
    (
      Icons.celebration_rounded,
      'Mahashivaratri',
      'February / March',
      'The most important festival. Hundreds of thousands gather for an overnight vigil with continuous aarti, abhishek, and Vedic chanting. Special Rudrabhishek is performed every hour through the night.',
      Color(0xFF4A148C),
    ),
    (
      Icons.water_rounded,
      'Simhastha Kumbh Mela',
      'Every 12 Years — Next: 2027',
      'Held once every 12 years at Trimbakeshwar & Nashik, drawing over 75 lakh (7.5 million) pilgrims. The Shahi Snan (royal bath) days are among the largest human gatherings on Earth.',
      Color(0xFF1565C0),
    ),
    (
      Icons.brightness_5_rounded,
      'Shravan Somvar',
      'Every Monday in July – August',
      'Each Monday during the holy month of Shravan is deeply auspicious for Shiva worship. The temple is open for extended hours with special abhishek rituals throughout the day.',
      Color(0xFF2E7D32),
    ),
    (
      Icons.nights_stay_rounded,
      'Amavasya (New Moon)',
      'Monthly',
      'Every new moon draws large crowds for Pind Daan, Tarpan, and Narayan Nagbali rituals. This is the most powerful day for ancestral peace rituals at Trimbakeshwar.',
      Color(0xFF37474F),
    ),
    (
      Icons.star_rounded,
      'Kartik Poornima',
      'October / November',
      'Thousands take a sacred dip in Kushavarta Kund and offer deepdan (floating lamps) on the water — creating a breathtaking visual spectacle of light and devotion.',
      Color(0xFFE65100),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.festivalsHeading, Icons.event_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _data.map((f) {
              final isKumbh = f.$2.contains('Simhastha') || f.$2.contains('Kumbh');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isKumbh ? null : Colors.white,
                  gradient: isKumbh
                      ? const LinearGradient(
                          colors: [Color(0xFFFFF8F0), Color(0xFFFFE5C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppL10n.s.festivalName(f.$2),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyDeep)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded,
                                      size: 11, color: AppColors.grey700),
                                  const SizedBox(width: 4),
                                  Text(AppL10n.s.festivalWhen(f.$3),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: f.$5,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(AppL10n.s.festivalDesc(f.$4),
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.grey700,
                            height: 1.6)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Poojas Summary ────────────────────────────────────────────────────────────

class _PoojasSummarySection extends StatefulWidget {
  const _PoojasSummarySection();

  @override
  State<_PoojasSummarySection> createState() => _PoojasSummarySectionState();
}

class _PoojasSummarySectionState extends State<_PoojasSummarySection> {
  static const _poojas = [
    (
      'Narayan Nagbali',
      Icons.auto_awesome_rounded,
      Color(0xFF4A148C),
      'Only place in India'
    ),
    (
      'Kalsarpa Shanti',
      Icons.all_inclusive_rounded,
      Color(0xFF006064),
      'Horoscope dosha remedy'
    ),
    (
      'Tripindi Shraddha',
      Icons.local_fire_department_rounded,
      Color(0xFF1565C0),
      'Ancestral peace ritual'
    ),
    (
      'Rudra Abhishek',
      Icons.water_drop_rounded,
      Color(0xFF2E7D32),
      'Sacred linga bathing'
    ),
    (
      'Mahamrityunjay Jaap',
      Icons.self_improvement_rounded,
      Color(0xFFBF360C),
      'Health & longevity'
    ),
    (
      'Laghu Rudra',
      Icons.brightness_5_rounded,
      Color(0xFF880E4F),
      'Powerful 11-priest yagna'
    ),
  ];

  @override
  void initState() {
    super.initState();
    PoojaService.load();
  }

  Future<void> _openPooja(String name) async {
    await PoojaService.load();

    // Try live server data first
    PoojaModel? match = PoojaService.poojas.value
        .where((p) => _nameMatches(p.name, name))
        .firstOrNull;

    // Fallback: build from local AppData so navigation always works
    if (match == null) {
      final local = AppData.poojas
          .where((p) => _nameMatches(p['name'] as String? ?? '', name))
          .firstOrNull;
      if (local != null) match = PoojaModel.fromAppData(local);
    }

    if (match != null && mounted) {
      Navigator.push(
        context,
        fadeSlideRoute((_) => PoojaDetailScreen(pooja: match!)),
      );
    }
  }

  static bool _nameMatches(String a, String b) {
    final x = a.toLowerCase().trim();
    final y = b.toLowerCase().trim();
    return x == y || x.startsWith(y) || y.startsWith(x);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.poojasSummary, Icons.celebration_rounded),
        const SizedBox(height: 14),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _poojas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final p = _poojas[i];
              return GestureDetector(
                onTap: () => _openPooja(p.$1),
                child: Container(
                  width: 132,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [p.$3, p.$3.withValues(alpha: 0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(p.$2, color: Colors.white, size: 18),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 9,
                              color: p.$3.withValues(alpha: 0.5)),
                        ],
                      ),
                      Text(AppL10n.s.poojaName(p.$1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDeep),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(AppL10n.s.poojaSummaryTag(p.$4),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.grey700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Sacred Sites ──────────────────────────────────────────────────────────────

class _SacredSitesSection extends StatelessWidget {
  const _SacredSitesSection();

  static final _sites = [
    ('Brahmagiri Parvat', AppImages.brahmagiriParvat),
    ('Kushavarta Kunda', AppImages.kushawartaKunda),
    ('Ganga Dwar', AppImages.gangaDwar),
    ('Muktidham Temple', AppImages.muktidhamTemple),
    ('Nivruttinath Temple', AppImages.nivruttinathTemple),
    ('Anjaneri Hills', AppImages.anjaneriHills),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.sacredSites, Icons.place_rounded),
        const SizedBox(height: 14),
        SizedBox(
          height: 135,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _sites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _SiteCard(name: _sites[i].$1, image: _sites[i].$2),
          ),
        ),
      ],
    );
  }
}

class _SiteCard extends StatelessWidget {
  final String name;
  final String image;
  const _SiteCard({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NearbyAttractionsScreen.openAttraction(context, name),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 145,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(src: image, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xCC000000), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 8,
              right: 8,
              child: Text(AppL10n.s.sacredSiteName(name),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                  maxLines: 2),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── How to Reach ──────────────────────────────────────────────────────────────

class _HowToReachSection extends StatelessWidget {
  const _HowToReachSection();

  static const _routes = [
    (
      Icons.flight_rounded,
      'By Air',
      'Nashik Airport (Ozar)',
      'Nashik (Ozar) Airport — 35 km\nMumbai International — 175 km (~3.5 hrs)',
      Color(0xFF1565C0)
    ),
    (
      Icons.train_rounded,
      'By Train',
      'Nashik Road Station',
      'Nashik Road — 40 km | Igatpuri — 45 km\nFrequent buses & taxis from both',
      Color(0xFF2E7D32)
    ),
    (
      Icons.directions_bus_rounded,
      'By Bus',
      'MSRTC & Private',
      'Direct buses from Mumbai, Pune, Nashik\nNashik ↔ Trimbak: ₹40–60 | 45 mins',
      Color(0xFFE65100)
    ),
    (
      Icons.two_wheeler_rounded,
      'Self Drive',
      'Via NH-3 Highway',
      'Mumbai → Nashik (160 km) → Trimbak\nPune → Nashik (210 km) → Trimbak',
      Color(0xFF6A1B9A)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(AppL10n.s.howToReach, Icons.directions_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _routes.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(r.$1, color: Colors.grey.shade500, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppL10n.s.routeMode(r.$2),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3)),
                          Text(AppL10n.s.routeHub(r.$3),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(AppL10n.s.routeDetail(r.$4),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.grey700,
                                  height: 1.55)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Visitor Guidelines ────────────────────────────────────────────────────────

class _VisitorGuidelinesSection extends StatelessWidget {
  const _VisitorGuidelinesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(AppL10n.s.visitorGuidelines, Icons.rule_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rule(true, AppL10n.s.visitorRule(
                    'Traditional attire — dhoti/kurta for men; saree or salwar for women')),
                _rule(true, AppL10n.s.visitorRule(
                    'Remove footwear before entering the temple premises')),
                _rule(true, AppL10n.s.visitorRule(
                    'Men must remove shirt inside the sanctum')),
                _rule(false, AppL10n.s.visitorRule(
                    'Shorts, jeans, sleeveless tops, and western wear not permitted')),
                _rule(false, AppL10n.s.visitorRule(
                    'Photography strictly prohibited inside the sanctum sanctorum')),
                _rule(false, AppL10n.s.visitorRule(
                    'Leather items (belts, bags, wallets) not allowed inside')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded,
                          color: Color(0xFFEF6C00), size: 17),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppL10n.s.visitorNote,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF5D4037),
                              height: 1.55),
                        ),
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

  Widget _rule(bool allowed, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: allowed
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : const Color(0xFFB71C1C).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(allowed ? Icons.check_rounded : Icons.close_rounded,
                  size: 13,
                  color: allowed
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFB71C1C)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.grey700, height: 1.5)),
            ),
          ],
        ),
      );
}

// ── Internal layout helpers ───────────────────────────────────────────────────

Widget _cardHeader(String title, IconData icon) => Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.06),
            Colors.transparent
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: _sectionHeading(title, icon),
    );

Widget _warnNote(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFF8F00), size: 17),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF795548), height: 1.5)),
            ),
          ],
        ),
      ),
    );

// ── Book a Pooja ──────────────────────────────────────────────────────────────

class _BookPoojaSection extends StatelessWidget {
  const _BookPoojaSection({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8D01E8), Color(0xFF3136D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D01E8).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Text(
                  'ॐ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    height: 1,
                    fontWeight: FontWeight.w300,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.s.bookPoojaHeading,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppL10n.s.bookPoojaSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    AppL10n.s.bookNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Guruji Contact Section ────────────────────────────────────────────────────
class _GurujiContactSection extends StatelessWidget {
  const _GurujiContactSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppL10n.s.contactGuruji,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Avatar + name
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: SizedBox.expand(
                child: AppImage(
                  src: AppImages.skGurujiCosmic1,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppL10n.s.gurujiNameLocalized,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppL10n.s.poojaServices,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 30),

          // Icon buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleContactButton(
                iconWidget: const Icon(Icons.phone_rounded, color: Color(0xFF2E7D32), size: 26),
                label: AppL10n.s.callLabel,
                color: const Color(0xFF2E7D32),
                onTap: () => UrlHelper.launch('tel:${AppStrings.phoneNumber}'),
              ),
              const SizedBox(width: 40),
              _CircleContactButton(
                iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF1B7F2E), size: 26),
                label: AppL10n.s.whatsappLabel,
                color: const Color(0xFF1B7F2E),
                onTap: () => UrlHelper.launch(AppStrings.whatsappUrl),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CircleContactButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CircleContactButton({
    required this.iconWidget,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color.withValues(alpha: 0.10),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Center(child: iconWidget),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
