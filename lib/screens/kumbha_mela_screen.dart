import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_l10n.dart';
import '../utils/app_images.dart';
import '../widgets/app_image.dart';

// ── Palette — matches card gradient (orange #FFB347 → yellow #FFE066) ─────────

const _saffron     = Color(0xFFFFB347);   // card gradient start
const _saffronDark = Color(0xFFE8920A);   // darker orange for accents
const _gold        = Color(0xFFFFE066);   // card gradient end
const _goldLight   = Color(0xFFFFFBE6);   // very light yellow background tint
const _cream       = Color(0xFFFFFDF5);   // page background
const _textDark    = Color(0xFF5D2E00);   // matches card text colour
const _textMid     = Color(0xFF7A4010);
const _textLight   = Color(0xFF9A6030);

class KumbhaMelaScreen extends StatefulWidget {
  const KumbhaMelaScreen({super.key});

  @override
  State<KumbhaMelaScreen> createState() => _KumbhaMelaScreenState();
}

class _KumbhaMelaScreenState extends State<KumbhaMelaScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  late final TabController _tabController;
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollCtrl.addListener(() {
      final opacity = (_scrollCtrl.offset / 240.0).clamp(0.0, 1.0);
      if ((opacity - _appBarOpacity).abs() > 0.01) {
        setState(() => _appBarOpacity = opacity);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _cream,
        body: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (ctx, _) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
              sliver: _buildAppBar(ctx),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: const [
              _OverviewTab(),
              _PlanVisitTab(),
              _SacredSitesTab(),
              _ServicesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Color.lerp(_saffron, _saffronDark, _appBarOpacity)!,
      elevation: 0,
      title: Opacity(
        opacity: _appBarOpacity,
        child: Text(
          AppL10n.s.kumbhaAppBarTitle,
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(src: AppImages.kumbhaMela, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xEE000000),
                    Color(0x66000000),
                    Color(0x22000000),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20, right: 20, bottom: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _saffron.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(AppL10n.s.kumbhaHeroLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(AppL10n.s.nashikTrimbakeshwar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                          )),
                      const SizedBox(width: 8),
                      const Text('2027',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 10)],
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: _gold,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        unselectedLabelStyle: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w500),
        tabs: [
          Tab(icon: const Icon(Icons.info_outline_rounded, size: 19),
              text: AppL10n.s.tabOverview),
          Tab(icon: const Icon(Icons.map_rounded, size: 19),
              text: AppL10n.s.tabPlanVisit),
          Tab(icon: const Icon(Icons.water_rounded, size: 19),
              text: AppL10n.s.tabSacredSites),
          Tab(icon: const Icon(Icons.miscellaneous_services_rounded, size: 19),
              text: AppL10n.s.tabServices),
        ],
      ),
    );
  }
}

// ── Countdown Banner ──────────────────────────────────────────────────────────

class _CountdownBanner extends StatelessWidget {
  const _CountdownBanner();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final target = DateTime(2027, 7, 9); // first Shahi Snan
    final days = target.difference(now).inDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_saffronDark, _gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _saffron.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('ॐ',
              style: TextStyle(fontSize: 32, color: _textDark, height: 1)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.s.firstShahiSnan,
                    style: const TextStyle(
                        color: _textMid,
                        fontSize: 11,
                        letterSpacing: 0.5)),
                SizedBox(height: 2),
                Text(AppL10n.s.kumbhaDateStr('9 July 2027'),
                    style: const TextStyle(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$days',
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              Text(AppL10n.s.daysToGo,
                  style: const TextStyle(
                      color: _textMid,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section heading ───────────────────────────────────────────────────────────

Widget _heading(String title, IconData icon) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4, height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_saffronDark, _gold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 20, color: _saffronDark),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textDark,
                letterSpacing: 0.3,
              )),
        ],
      ),
    );

BoxDecoration _card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );

// ── Important Dates ───────────────────────────────────────────────────────────

class _ImportantDatesSection extends StatelessWidget {
  const _ImportantDatesSection();

  static const _dates = [
    (
      'Pratipada Snan',
      '9 July 2027',
      'Opening holy bath — Shravana Shukla Pratipada',
      Icons.water_drop_rounded,
      _saffron,
      true,
    ),
    (
      'Naga Sadhu Shahi Snan',
      '24 July 2027',
      'Shravana Purnima — Grand procession of Naga Sadhus',
      Icons.brightness_5_rounded,
      Color(0xFF6A1B9A),
      true,
    ),
    (
      'Second Shahi Snan',
      '8 August 2027',
      'Bhadrapada Shukla Pratipada — Major Akhada bath',
      Icons.waves_rounded,
      Color(0xFF1565C0),
      true,
    ),
    (
      'Third Shahi Snan',
      '22 August 2027',
      'Bhadrapada Amavasya — Pitru Tarpan & mass bath',
      Icons.nightlight_rounded,
      Color(0xFF2E7D32),
      false,
    ),
    (
      'Kumbha Parikrama',
      '1 Sept 2027',
      'Final sacred circumambulation — closing ceremony',
      Icons.loop_rounded,
      _textMid,
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(AppL10n.s.importantDates, Icons.calendar_month_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _dates.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6)),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(d.$4, color: d.$5, size: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(AppL10n.s.kumbhaDateName(d.$1),
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: d.$5)),
                                ),
                                if (d.$6)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: d.$5.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(AppL10n.s.shahiLabel,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: d.$5,
                                            letterSpacing: 0.8)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(AppL10n.s.kumbhaDateStr(d.$2),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _textDark)),
                            const SizedBox(height: 2),
                            Text(AppL10n.s.kumbhaDateSub(d.$3),
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: _textLight,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Event Highlights ──────────────────────────────────────────────────────────

class _EventHighlightsSection extends StatelessWidget {
  const _EventHighlightsSection();

  static const _highlights = [
    (Icons.brightness_5_rounded, 'Shahi Snan',
        'Grand royal bathing processions of Naga Sadhus and Akhadas on auspicious dates', Color(0xFFE65100)),
    (Icons.celebration_rounded, 'Aarti & Bhajans',
        'Daily Ganga Aarti at Ramkund & Kushavarta Kund with thousands of deepa (lamps)', Color(0xFF6A1B9A)),
    (Icons.groups_rounded, 'Akhada Camps',
        'Over 13 Akhadas set up grand camps — Juna, Niranjani, Mahanirvani and more', Color(0xFF1565C0)),
    (Icons.local_fire_department_rounded, 'Havan & Yagnas',
        'Continuous Vedic rituals, Rudrabhishek and fire ceremonies throughout the event', Color(0xFF2E7D32)),
    (Icons.self_improvement_rounded, 'Sadhus & Saints',
        'Millions of saints, ascetics and spiritual leaders gather from across India', _saffronDark),
    (Icons.volunteer_activism_rounded, 'Annadaan',
        'Free meals (prasad) served to lakhs of pilgrims daily by ashrams and trusts', Color(0xFF37474F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(AppL10n.s.eventHighlights, Icons.star_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: _card(),
            child: Column(
              children: List.generate(_highlights.length, (i) {
                final h = _highlights[i];
                final isLast = i == _highlights.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(h.$1, color: h.$4, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppL10n.s.kumbhaHighlightName(h.$2),
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: h.$4)),
                                const SizedBox(height: 3),
                                Text(AppL10n.s.kumbhaHighlightDesc(h.$3),
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: _textLight,
                                        height: 1.55)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 70,
                          endIndent: 16,
                          color: Colors.grey.shade100),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Plan Your Visit ───────────────────────────────────────────────────────────

class _PlanYourVisitSection extends StatelessWidget {
  const _PlanYourVisitSection();

  static const _cards = [
    (
      Icons.hotel_rounded,
      'Stay',
      'Accommodation',
      'Ashram dorms from ₹300/night. Tents, dharamshalas & hotels in Nashik/Trimbak. Book 3–6 months early.',
      Color(0xFF1565C0),
    ),
    (
      Icons.restaurant_rounded,
      'Food',
      'Prasad & Dining',
      'Free langar at Akhada camps. Vegetarian thalis in temple market. Carry water bottles — queues are long.',
      Color(0xFF2E7D32),
    ),
    (
      Icons.directions_bus_rounded,
      'Transport',
      'Getting There',
      'Special MSRTC buses from Nashik, Pune & Mumbai. Shuttle buses within the mela grounds.',
      _saffronDark,
    ),
    (
      Icons.health_and_safety_rounded,
      'Safety',
      'Crowd & Health',
      'Carry ID proof & emergency contacts. Medical camps throughout the grounds. Wear visible clothing on Shahi Snan days.',
      Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(AppL10n.s.planYourVisit, Icons.map_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _cards.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6)),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(c.$1, color: c.$5, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppL10n.s.kumbhaPlanCategory(c.$3),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: c.$5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3)),
                          Text(AppL10n.s.kumbhaPlanTitle(c.$2),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark)),
                          const SizedBox(height: 5),
                          Text(AppL10n.s.kumbhaPlanDesc(c.$4),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: _textLight,
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

// ── Ghats ─────────────────────────────────────────────────────────────────────

const _ghatsBlue      = Color(0xFF0D47A1);
const _ghatsTeal      = Color(0xFF00695C);
const _ghatsLightBlue = Color(0xFFE3F2FD);

class _GhatsSection extends StatelessWidget {
  const _GhatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Important Ghats', Icons.water_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nashik ──────────────────────────────────────────────────
              _subLabel('Nashik Ghats', Icons.location_city_rounded, _ghatsBlue),
              const SizedBox(height: 10),
              // Ramkund hero
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _ghatsBlue.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔱', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 5),
                                Text('MAIN GHAT',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.waves_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 22),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Ramkund',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          )),
                      const SizedBox(height: 10),
                      ...[
                        'Most sacred bathing spot in Nashik',
                        'Associated with Lord Rama',
                        'Highly crowded during Shahi Snan',
                      ].map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.8)),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(t,
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.92),
                                          fontSize: 13,
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Other key ghats card
              Container(
                decoration: BoxDecoration(
                  color: _ghatsLightBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _ghatsBlue.withValues(alpha: 0.15), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.waves_rounded,
                            size: 16, color: _ghatsBlue),
                        const SizedBox(width: 7),
                        const Text('Other Key Ghats',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _ghatsBlue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Laxman Kund',
                        'Kapaleshwar Ghat',
                        'Goda Ghat',
                        'Panchavati Ghats',
                      ]
                          .map((g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _ghatsBlue.withValues(alpha: 0.10),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.water_drop_rounded,
                                        size: 11, color: _ghatsBlue),
                                    const SizedBox(width: 5),
                                    Text(g,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: _ghatsBlue)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // ── Trimbakeshwar ────────────────────────────────────────────
              _subLabel('Trimbakeshwar Ghats', Icons.location_on_rounded, _ghatsTeal),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _ghatsTeal.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔱', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 5),
                                Text('PRIMARY SNAN',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.spa_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 22),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Kushavarta Kund',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          )),
                      const SizedBox(height: 10),
                      ...[
                        'Origin point of the Godavari River (spiritually)',
                        'Primary snan location in Trimbak',
                      ].map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.8)),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(t,
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.92),
                                          fontSize: 13,
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subLabel(String title, IconData icon, Color color) => Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5)),
        ],
      );
}

// ── Akhadas ───────────────────────────────────────────────────────────────────

const _akhShaiva   = Color(0xFFE65100);
const _akhVaishnav = Color(0xFF558B2F);
const _akhUdasin   = Color(0xFF880E4F);

class _AkhadasSection extends StatelessWidget {
  const _AkhadasSection();

  static const _groups = [
    (
      '🟠',
      'Shaiva Akhadas',
      'Shiva followers',
      _akhShaiva,
      ['Juna Akhada', 'Niranjani Akhada', 'Mahanirvani Akhada', 'Atal Akhada'],
    ),
    (
      '🟡',
      'Vaishnava Akhadas',
      'Vishnu followers',
      _akhVaishnav,
      ['Nirmohi Akhada', 'Digambar Ani Akhada'],
    ),
    (
      '🔴',
      'Udasin & Others',
      '',
      _akhUdasin,
      ['Bada Udasin Akhada', 'Naya Udasin Akhada'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Akhadas', Icons.groups_rounded),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Monastic warrior groups of sadhus who lead the Shahi Snan procession.',
            style: TextStyle(
                fontSize: 13, color: _textLight, height: 1.5),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Group cards
              ..._groups.map((g) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: g.$4.withValues(alpha: 0.18), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: g.$4.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            color: g.$4.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(13)),
                            border: Border(
                                bottom: BorderSide(
                                    color: g.$4.withValues(alpha: 0.15))),
                          ),
                          child: Row(
                            children: [
                              Text(g.$1,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(g.$2,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: g.$4)),
                              if (g.$3.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: g.$4.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(g.$3,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: g.$4)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Akhada chips
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: g.$5
                                .map((name) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 13, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: g.$4.withValues(alpha: 0.07),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: g.$4.withValues(alpha: 0.25)),
                                      ),
                                      child: Text(name,
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: g.$4)),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  )),
              // Naga Sadhus highlight
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade700.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👉',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Naga Sadhus',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 5),
                          Text(
                            'Ash-covered ascetics who appear only during Shahi Snan — '
                            'a rare and deeply sacred sight for pilgrims.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Services ──────────────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(AppL10n.s.servicesLabel, Icons.miscellaneous_services_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.auto_awesome_rounded,
                  label: AppL10n.s.poojaBookingCard,
                  color: _saffron,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.hotel_rounded,
                  label: AppL10n.s.roomsCard,
                  color: const Color(0xFF1565C0),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _goldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded, color: _saffronDark, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppL10n.s.kumbhaServiceNote,
                    style: const TextStyle(
                        fontSize: 12.5, color: _textMid, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// ── Map & Navigation ──────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection();

  static const _mapUrl =
      'https://maps.google.com/?q=Trimbakeshwar+Temple,+Nashik,+Maharashtra';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(AppL10n.s.mapNavigation, Icons.map_rounded),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: _card(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Map preview placeholder
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines (faux map)
                      CustomPaint(
                        size: const Size(double.infinity, 160),
                        painter: _MapGridPainter(),
                      ),
                      // Pin
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: _saffronDark, size: 44),
                            const Text('Trimbakeshwar',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark)),
                            Text(AppL10n.s.kumbhaGrounds2027,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: _textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _locationRow(Icons.place_rounded,
                          AppL10n.s.kumbhaLocation),
                      const SizedBox(height: 8),
                      _locationRow(Icons.directions_car_rounded,
                          AppL10n.s.kumbhaDistance),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse(_mapUrl),
                              mode: LaunchMode.externalApplication),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _saffronDark,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(AppL10n.s.viewFullMap,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _locationRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _saffron),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: _textMid, height: 1.5)),
          ),
        ],
      );
}

// ── Tab bodies ────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('tab_overview'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16, bottom: 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _CountdownBanner(),
              SizedBox(height: 20),
              _ImportantDatesSection(),
              SizedBox(height: 24),
              _EventHighlightsSection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PlanVisitTab extends StatelessWidget {
  const _PlanVisitTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('tab_plan'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16, bottom: 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _PlanYourVisitSection(),
              SizedBox(height: 24),
              _MapSection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SacredSitesTab extends StatelessWidget {
  const _SacredSitesTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('tab_sacred'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16, bottom: 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _GhatsSection(),
              SizedBox(height: 24),
              _AkhadasSection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('tab_services'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16, bottom: 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _ServicesSection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // "Roads"
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        roadPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
