import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_l10n.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

const _imgBase = 'https://app.trimbakeshwarpoojavidhi.in/uploads/images';

class _Jyotirlinga {
  final int number;
  final String name;
  final String state;
  final String location;
  final String description;
  final Color accent;
  final bool isHome;
  final String? imageUrl;

  const _Jyotirlinga({
    required this.number,
    required this.name,
    required this.state,
    required this.location,
    required this.description,
    required this.accent,
    this.isHome = false,
    this.imageUrl,
  });
}

const _list = [
  _Jyotirlinga(
    number: 1, name: 'Somnath', state: 'Gujarat',
    location: 'Prabhas Patan, Veraval',
    description: 'The first Jyotirlinga — built by the Moon God in gold, silver and stone to appease Lord Shiva after a curse.',
    accent: Color(0xFFD4A017),
    imageUrl: '$_imgBase/somnath.jpg',
  ),
  _Jyotirlinga(
    number: 2, name: 'Mallikarjuna', state: 'Andhra Pradesh',
    location: 'Srisailam',
    description: 'On the Nallamala hills above the Krishna river — also a Shakti Peetha, doubly auspicious for devotees.',
    accent: Color(0xFF2E7D32),
    imageUrl: '$_imgBase/shri-mallikarjuna-jyotirlinga-temple-display.jpg',
  ),
  _Jyotirlinga(
    number: 3, name: 'Mahakaleshwar', state: 'Madhya Pradesh',
    location: 'Ujjain',
    description: 'The only south-facing Dakshinamukhi Jyotirlinga. The Bhasma Aarti at dawn is one of the most powerful Hindu rituals.',
    accent: Color(0xFF7B1FA2),
    imageUrl: '$_imgBase/mahakaleshwar-temple.jpg',
  ),
  _Jyotirlinga(
    number: 4, name: 'Omkareshwar', state: 'Madhya Pradesh',
    location: 'Mandhata Island',
    description: 'On the OM-shaped island in the Narmada — where 33 crore Gods assemble to worship Lord Shiva.',
    accent: Color(0xFFE65100),
    imageUrl: '$_imgBase/omkareshwar.jpg',
  ),
  _Jyotirlinga(
    number: 5, name: 'Kedarnath', state: 'Uttarakhand',
    location: 'Rudraprayag',
    description: 'Perched at 3,583m in the Himalayas — the most challenging and spiritually elevating pilgrimage, open 6 months a year.',
    accent: Color(0xFF1565C0),
    imageUrl: '$_imgBase/kedarnath.jpg',
  ),
  _Jyotirlinga(
    number: 6, name: 'Bhimashankar', state: 'Maharashtra',
    location: 'Sahyadri Hills',
    description: 'Hidden in the misty Sahyadri forests. Shiva slew the demon Tripurasur here; the Bhima river originates from this hill.',
    accent: Color(0xFF00796B),
    imageUrl: '$_imgBase/Bhimashankar-Jyotirlinga3-1.jpg.webp',
  ),
  _Jyotirlinga(
    number: 7, name: 'Kashi Vishwanath', state: 'Uttar Pradesh',
    location: 'Varanasi',
    description: 'The Golden Temple on the Ganga — Lord Shiva whispers the Taraka Mantra into the ears of the dying here.',
    accent: Color(0xFFC62828),
    imageUrl: '$_imgBase/shri-kashi-vishwanath-300x300.jpg',
  ),
  _Jyotirlinga(
    number: 8, name: 'Trimbakeshwar', state: 'Maharashtra',
    location: 'Trimbak, Nashik',
    description: 'The only Jyotirlinga with three faces — Brahma, Vishnu and Shiva. Located at the source of the sacred Godavari river.',
    accent: Color(0xFFC89030),
    isHome: true,
    imageUrl: '$_imgBase/trimbakeshwar-jyotirling-mandir-650291.jpg',
  ),
  _Jyotirlinga(
    number: 9, name: 'Vaidyanath', state: 'Jharkhand',
    location: 'Deoghar',
    description: 'Renowned for healing powers. Ravana worshipped Shiva here and offered his ten heads as sacrifice.',
    accent: Color(0xFF00838F),
    imageUrl: '$_imgBase/vaidyanath.png',
  ),
  _Jyotirlinga(
    number: 10, name: 'Nageshwar', state: 'Gujarat',
    location: 'Dwarka',
    description: 'The Lord of Serpents — protects devotees from all poisons. A 25-metre Shiva statue marks this powerful pilgrimage site.',
    accent: Color(0xFFF57F17),
    imageUrl: '$_imgBase/nageshwar.jpg',
  ),
  _Jyotirlinga(
    number: 11, name: 'Rameshwaram', state: 'Tamil Nadu',
    location: 'Rameswaram',
    description: 'Installed by Lord Rama before crossing to Lanka. One of the Char Dhams with the world\'s longest temple corridor.',
    accent: Color(0xFFAD1457),
    imageUrl: '$_imgBase/rameshwaram.webp',
  ),
  _Jyotirlinga(
    number: 12, name: 'Grishneshwar', state: 'Maharashtra',
    location: 'Verul, Aurangabad',
    description: 'The last Jyotirlinga, near the Ellora caves. Shiva fulfils every heartfelt wish and liberates souls from rebirth.',
    accent: Color(0xFF4527A0),
    imageUrl: '$_imgBase/Grishneshwar-Jyotirlinga-Mobile.webp',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class JyotirlingaScreen extends StatefulWidget {
  const JyotirlingaScreen({super.key});

  @override
  State<JyotirlingaScreen> createState() => _JyotirlingaScreenState();
}

class _JyotirlingaScreenState extends State<JyotirlingaScreen> {
  static const _gold = Color(0xFFE8A020);
  static const _goldBright = Color(0xFFF2C44A);

  final _scrollCtrl = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final offset = _scrollCtrl.offset;
      // Start fading in at 300px, fully visible at 420px (end of hero)
      final opacity = ((offset - 300) / 120).clamp(0.0, 1.0);
      if (opacity != _appBarOpacity) {
        setState(() => _appBarOpacity = opacity);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        dark: true,
        onTap: (i) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: i)),
          (_) => false,
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: _appBarOpacity),
            boxShadow: _appBarOpacity > 0.5
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4 * _appBarOpacity),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Opacity(
              opacity: _appBarOpacity,
              child: Text(
                AppL10n.s.twelveJyotirlingas,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white.withValues(alpha: 0.3 + 0.7 * _appBarOpacity),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        child: Column(
          children: [
            _buildHero(context),
            _buildSectionLabel(),
            _buildGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      width: w,
      height: 430,
      child: Stack(
        children: [
          // ── Full bleed background image ───────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: '$_imgBase/trimbakeshwar_linga.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ── Overall dark tint so the image doesn't overpower ──────────
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ),

          // ── Left darkening gradient (text readability) ────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.38, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Top fade (AppBar blend) ───────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom fade — hard merge into black grid section ──────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x55000000),
                    Color(0xCC000000),
                    Colors.black,
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Text content ──────────────────────────────────────────────
          Positioned(
            left: 22,
            top: 95,
            right: w * 0.38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large "12"
                const Text(
                  '12',  // number stays numeric
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.w900,
                    color: _goldBright,
                    height: 0.88,
                    shadows: [
                      Shadow(color: Color(0xFFE88020), blurRadius: 30),
                      Shadow(color: Color(0xFFF2C44A), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppL10n.s.jyotirlingasWord,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: _gold,
                    letterSpacing: 3.5,
                    height: 1,
                    shadows: [
                      Shadow(color: Color(0xFFE88020), blurRadius: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppL10n.s.divineAbodesShiva,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Ornamental divider with trident
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: _gold.withValues(alpha: 0.7),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('🔱', style: TextStyle(fontSize: 14)),
                    ),
                    Container(
                      width: 24,
                      height: 1,
                      color: _gold.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '|| ॐ नमः शिवाय ||',
                  style: TextStyle(
                    fontSize: 15,
                    color: _goldBright,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Color(0xFFE88020), blurRadius: 16),
                      Shadow(color: Colors.black, blurRadius: 6),
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

  Widget _buildSectionLabel() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 28, height: 1, color: _gold.withValues(alpha: 0.6)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '❯',
              style: TextStyle(color: _gold, fontSize: 11),
            ),
          ),
          Text(
            AppL10n.s.exploreJyotirlingas,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: 2.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '❮',
              style: TextStyle(color: _gold, fontSize: 11),
            ),
          ),
          Container(width: 28, height: 1, color: _gold.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _list.length,
        itemBuilder: (_, i) => _GridCard(data: _list[i]),
      ),
    );
  }
}

// ── Grid Card ─────────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final _Jyotirlinga data;
  const _GridCard({required this.data});

  static const _gold = Color(0xFFE8A020);
  static const _goldBright = Color(0xFFF2C44A);

  @override
  Widget build(BuildContext context) {
    final isHome = data.isHome;
    final accent = data.accent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHome
              ? _goldBright.withValues(alpha: 0.7)
              : _gold.withValues(alpha: 0.3),
          width: isHome ? 1.5 : 1,
        ),
        boxShadow: isHome
            ? [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      // Stack without ClipRRect — use overflow clipping via Container borderRadius only
      child: Stack(
        children: [
          // ── Background: photo or atmospheric gradient ─────────────────
          if (data.imageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: data.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
          else ...[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
            Positioned(
              top: -20, left: 0, right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.0,
                    colors: [
                      accent.withValues(alpha: isHome ? 0.55 : 0.4),
                      accent.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${data.number}',
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: accent.withValues(alpha: 0.08),
                    height: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8, left: 0, right: 0,
              child: Opacity(
                opacity: isHome ? 0.6 : 0.3,
                child: CachedNetworkImage(
                  imageUrl: '$_imgBase/shiva_meditating.png',
                  height: 95,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
          // Bottom dark overlay for text readability (always shown)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // ── Number badge (top-left) ──────────────────────────────────
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isHome ? _gold : const Color(0xFF1A1200),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _gold.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Text(
                '${data.number}',
                style: TextStyle(
                  color: isHome ? Colors.black : _goldBright,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          // ── Home glow dot (top-right for Trimbakeshwar) ───────────────
          if (isHome)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _goldBright,
                  boxShadow: [
                    BoxShadow(
                      color: _goldBright,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          // ── Temple name + state (bottom) ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppL10n.s.jyotirlingaName(data.name),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isHome ? _goldBright : Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 0.8,
                        color: _gold.withValues(alpha: 0.4),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gold.withValues(alpha: 0.7),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 0.8,
                        color: _gold.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppL10n.s.jyotirlingaState(data.state),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 9.5,
                      letterSpacing: 0.2,
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
