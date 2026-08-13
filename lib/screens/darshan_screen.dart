import 'package:flutter/material.dart';
import '../constants/app_l10n.dart';
import '../services/language_service.dart';
import '../utils/app_images.dart';
import '../widgets/app_image.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _saffron     = Color(0xFF1976D2);
const _saffronDark = Color(0xFF1565C0);
const _navyText    = Color(0xFF0D2137);
const _greyText    = Color(0xFF546E7A);
const _bgSurface   = Color(0xFFF5F6FA);
const _green       = Color(0xFF2E7D32);

// ── Schedule data ─────────────────────────────────────────────────────────────
class _Timing {
  final String name, subtitle, time;
  final Color color;
  final IconData icon;
  const _Timing(this.name, this.subtitle, this.time, this.color, this.icon);
}

const _schedule = [
  _Timing('Temple Opens',        'Daily',         '5:30 AM',              Color(0xFFFF8F00), Icons.brightness_5_rounded),
  _Timing('Brahma Puja',         'Morning Puja',  '7:00 – 8:30 AM',       Color(0xFF6A1B9A), Icons.local_fire_department_rounded),
  _Timing('Mahadev Puja',        'Midday Puja',   '10:45 AM – 12:30 PM',  Color(0xFF2E7D32), Icons.wb_sunny_rounded),
  _Timing('Vishnu Puja & Aarti', 'Evening Puja',  '7:00 – 8:30 PM',       Color(0xFF1565C0), Icons.wb_twilight_rounded),
  _Timing('Temple Closes',       'Daily',         '9:00 PM',              Color(0xFF37474F), Icons.nightlight_rounded),
];

// ── Process steps ─────────────────────────────────────────────────────────────
class _Step {
  final IconData icon;
  final String title, desc;
  const _Step(this.icon, this.title, this.desc);
}

const _steps = [
  _Step(Icons.local_parking_rounded,
    'Arrive & Park',
    'Paid parking is available near the main entrance. Two-wheelers and four-wheelers have separate designated areas.'),
  _Step(Icons.luggage_rounded,
    'Deposit Footwear & Belongings',
    'Remove footwear at the shoe stand near the entrance. Deposit leather items (belts, bags, wallets) at the cloak room. Lockers available for a small fee.'),
  _Step(Icons.checkroom_rounded,
    'Dress Check at Entry',
    'Men must remove their shirts before entering the sanctum. Women should cover their head with a dupatta or saree pallu. Temporary clothing is available at the gate.'),
  _Step(Icons.people_rounded,
    'Join the Queue',
    'Separate queues are maintained for men and women. Collect a token slip if the crowd is heavy. Follow the marked lane guides inside the complex.'),
  _Step(Icons.security_rounded,
    'Security Check',
    'A light check at the inner gate. Only flowers, bilva leaves, and small coconuts are permitted inside the sanctum. No bags or phones allowed.'),
  _Step(Icons.temple_hindu_rounded,
    'Enter the Sabha Mandap',
    'Proceed into the main hall (assembly mandap). Maintain complete silence. Chant "Om Namah Shivaya" silently as you move towards the inner sanctum.'),
  _Step(Icons.auto_awesome_rounded,
    'Darshan of the Jyotirlinga',
    'The priest will guide your offering. You will view the Triple-Faced Jyotirlinga from very close proximity. Darshan lasts approximately 20–40 seconds per group.'),
  _Step(Icons.rotate_right_rounded,
    'Perform Parikrama',
    'Circumambulate the sanctum clockwise once (parikrama). This is considered the completion and sealing of your darshan before you exit.'),
  _Step(Icons.favorite_rounded,
    'Receive Prasad & Exit',
    'The priest offers vibhuti (sacred ash) and prasad. Accept with both hands as a sacred blessing. Exit via the marked gate and collect your footwear.'),
];

// ── Darshan types ─────────────────────────────────────────────────────────────
class _DType {
  final IconData icon;
  final String label, sublabel, desc;
  final Color color;
  const _DType(this.icon, this.label, this.sublabel, this.desc, this.color);
}

const _types = [
  _DType(Icons.people_rounded,
    'Free General Darshan', 'No entry fee',
    'Open to all devotees. Expected wait: 1–2 hrs on weekdays, 3–6 hrs on weekends and festival days.',
    Color(0xFF2E7D32)),
  _DType(Icons.account_balance_rounded,
    'Pandit-Guided Darshan', 'Through Guruji',
    'Arranged via a registered Guruji. Includes a dedicated queue, ritual guidance, and personalised pooja support throughout.',
    Color(0xFF6A1B9A)),
  _DType(Icons.water_drop_rounded,
    'Abhishek Darshan', 'With Special Pooja',
    'Book a Rudrabhishek slot (7–11 AM). Performed directly at the Jyotirlinga with the priest performing the ritual alongside you.',
    Color(0xFF1565C0)),
  _DType(Icons.star_rounded,
    'VIP / Special Darshan', 'For special needs',
    'Available via application to the Devasthan Trust for elderly devotees, differently abled pilgrims, or those with specific requirements.',
    Color(0xFFE65100)),
];

// ─────────────────────────────────────────────────────────────────────────────

class DarshanScreen extends StatefulWidget {
  const DarshanScreen({super.key});

  @override
  State<DarshanScreen> createState() => _DarshanScreenState();
}

class _DarshanScreenState extends State<DarshanScreen> {
  @override
  void initState() {
    super.initState();
    LanguageService.isHindi.addListener(_onLang);
  }

  void _onLang() => setState(() {});

  @override
  void dispose() {
    LanguageService.isHindi.removeListener(_onLang);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSurface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _TodayHoursCard(),
                  SizedBox(height: 20),
                  _ScheduleCard(),
                  SizedBox(height: 20),
                  _ProcessCard(),
                  SizedBox(height: 20),
                  _DarshanTypesCard(),
                  SizedBox(height: 20),
                  _DressCodeCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: const Color(0xFF1565C0),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
        title: Text(
          AppL10n.s.darshanAppBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              src: AppImages.trimbakeshwarTemple,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1565C0).withValues(alpha: 0.92),
                    const Color(0xFF1976D2).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 58,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppL10n.s.darshanOpenBadge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
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

// ── Today Hours Card ──────────────────────────────────────────────────────────

class _TodayHoursCard extends StatelessWidget {
  const _TodayHoursCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.access_time_rounded,
                    color: _green, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppL10n.s.darshanTodayTitle,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _navyText)),
                    Text(AppL10n.s.darshanTodaySubtitle,
                        style: const TextStyle(fontSize: 11, color: _greyText)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(AppL10n.s.darshanOpenLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _green)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _session(AppL10n.s.darshanOpensLabel, AppL10n.s.darshanOpenTime, const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          _session(AppL10n.s.darshanClosesLabel, AppL10n.s.darshanCloseTime, const Color(0xFFB71C1C)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: Color(0xFFE65100)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppL10n.s.darshanTimingNote,
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF5D4037),
                        height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _session(String label, String time, Color color) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const Spacer(),
        Text(time,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ── Schedule Card ─────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(AppL10n.s.darshanScheduleHeader, Icons.schedule_rounded),
          ...List.generate(_schedule.length, (i) {
            final s = _schedule[i];
            final isLast = i == _schedule.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppL10n.s.timingSubtitle(s.subtitle),
                                style: const TextStyle(
                                    fontSize: 10.5, color: _greyText)),
                            const SizedBox(height: 1),
                            Text(AppL10n.s.timingName(s.name),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _navyText)),
                          ],
                        ),
                      ),
                      Text(AppL10n.s.darshanScheduleTime(s.time),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: s.color)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFFF8F00), size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppL10n.s.darshanTimingNote,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF795548),
                          height: 1.45),
                    ),
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

// ── Special Days Card ─────────────────────────────────────────────────────────

class _SpecialDaysCard extends StatelessWidget {
  const _SpecialDaysCard();

  static const _days = [
    (Icons.brightness_5_rounded, 'Shravan Mondays',   'July – Aug',        'Temple opens at 4:00 AM. Extended darshan all day with special Rudrabhishek performed every hour.',           Color(0xFF2E7D32)),
    (Icons.celebration_rounded,  'Mahashivaratri',    'Feb / March',       'All-night vigil. Temple stays open through the night with continuous aarti, abhishek, and chanting.',         Color(0xFF6A1B9A)),
    (Icons.nights_stay_rounded,  'Amavasya (New Moon)','Monthly',          'Extended morning hours. Most auspicious day for Pind Daan, Tarpan, and Narayan Nagbali rituals.',            Color(0xFF37474F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        children: [
          _header('Special Day Timings', Icons.event_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: _days
                  .map((d) => Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: d.$5.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: d.$5.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: d.$5.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(d.$1, color: d.$5, size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(d.$2,
                                            style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: _navyText)),
                                      ),
                                      Text(d.$3,
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              color: d.$5,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(d.$4,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: _greyText,
                                          height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Process Card ──────────────────────────────────────────────────────────────

class _ProcessCard extends StatelessWidget {
  const _ProcessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(AppL10n.s.darshanProcessHeader, Icons.directions_walk_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: List.generate(
                _steps.length,
                (i) => _StepRow(
                  step: _steps[i],
                  number: i + 1,
                  isLast: i == _steps.length - 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final int number;
  final bool isLast;

  const _StepRow(
      {required this.step, required this.number, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_saffron, _saffronDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800),
                  ),
                ),
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
              if (!isLast) const SizedBox(height: 6),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step.icon, size: 14, color: _saffronDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(AppL10n.s.darshanStepTitle(step.title),
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _navyText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(AppL10n.s.darshanStepDesc(step.desc),
                      style: const TextStyle(
                          fontSize: 12.5, color: _greyText, height: 1.55)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Darshan Types Card ────────────────────────────────────────────────────────

class _DarshanTypesCard extends StatelessWidget {
  const _DarshanTypesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        children: [
          _header(AppL10n.s.darshanTypesHeader, Icons.category_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: _types
                  .map((t) => Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                                color: t.color.withValues(alpha: 0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [t.color, t.color.withValues(alpha: 0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(t.icon, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppL10n.s.darshanTypeName(t.label),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _navyText)),
                                  Text(AppL10n.s.darshanTypeSublabel(t.sublabel),
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          color: t.color,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 5),
                                  Text(AppL10n.s.darshanTypeDesc(t.desc),
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: _greyText,
                                          height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dress Code Card ───────────────────────────────────────────────────────────

class _DressCodeCard extends StatelessWidget {
  const _DressCodeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(AppL10n.s.darshanDressHeader, Icons.checkroom_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sub(AppL10n.s.darshanMen),
                _rule(true,  AppL10n.s.darshanRule('White or saffron dhoti — the most appropriate attire')),
                _rule(true,  AppL10n.s.darshanRule('Kurta-pyjama or dhoti with angavastra (upper cloth)')),
                _rule(false, AppL10n.s.darshanRule('Shirts must be removed before entering the sanctum')),
                _rule(false, AppL10n.s.darshanRule('Shorts, jeans, and western wear are not permitted')),
                const SizedBox(height: 10),
                _sub(AppL10n.s.darshanWomen),
                _rule(true,  AppL10n.s.darshanRule('Saree (preferred) or salwar-kameez with dupatta')),
                _rule(true,  AppL10n.s.darshanRule('Cover head with dupatta or saree pallu inside the temple')),
                _rule(false, AppL10n.s.darshanRule('Skirts, sleeveless tops, and western wear not permitted')),
                const SizedBox(height: 10),
                _sub(AppL10n.s.darshanAllDevotees),
                _rule(false, AppL10n.s.darshanRule('Leather items — belts, bags, wallets — must be deposited outside')),
                _rule(false, AppL10n.s.darshanRule('Photography and mobile phones strictly prohibited in the sanctum')),
                _rule(true,  AppL10n.s.darshanRule('Footwear removed before the main entrance — shoe stand is provided')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sub(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _saffronDark,
                letterSpacing: 0.8)),
      );

  Widget _rule(bool allowed, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: allowed
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : const Color(0xFFB71C1C).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                allowed ? Icons.check_rounded : Icons.close_rounded,
                size: 12,
                color: allowed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: _greyText, height: 1.5)),
            ),
          ],
        ),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

BoxDecoration _cardDecor() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4)),
      ],
    );

Widget _header(String title, IconData icon) => Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_saffron.withValues(alpha: 0.07), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_saffron, _saffronDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _navyText,
                  letterSpacing: 0.2)),
        ],
      ),
    );
