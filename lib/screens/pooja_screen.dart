import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../models/pooja_model.dart';
import '../services/auth_service.dart';
import '../services/pooja_service.dart';
import '../utils/app_images.dart';
import '../utils/app_route.dart';
import '../widgets/app_image.dart';
import 'booking_screen.dart';
import 'login_screen.dart';
import 'pooja_detail_screen.dart';

class PoojaScreen extends StatefulWidget {
  const PoojaScreen({super.key});

  @override
  State<PoojaScreen> createState() => _PoojaScreenState();
}

class _PoojaScreenState extends State<PoojaScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  bool _showBar = false;
  bool _searching = false;
  String _searchQuery = '';
  late final TextEditingController _searchCtrl;
  late final AnimationController _searchAnim;
  late final Animation<double> _searchExpand;

  static const double _heroHeight = 340;

  @override
  void initState() {
    super.initState();
    PoojaService.load(force: true, silent: true);
    _scroll.addListener(_onScroll);
    _searchCtrl = TextEditingController();
    _searchAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _searchExpand =
        CurvedAnimation(parent: _searchAnim, curve: Curves.easeOut);
  }

  void _onScroll() {
    final show = _scroll.offset > _heroHeight - 80;
    if (show != _showBar) setState(() => _showBar = show);
  }

  void _triggerSearch() {
    setState(() => _showBar = true);
    _openSearch();
    _scroll.animateTo(
      _heroHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _openSearch() {
    setState(() => _searching = true);
    _searchAnim.forward();
  }

  void _closeSearch() {
    _searchAnim.reverse().then((_) {
      setState(() {
        _searching = false;
        _searchQuery = '';
      });
      _searchCtrl.clear();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _searchCtrl.dispose();
    _searchAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // ── Scrollable content ───────────────────────────────────────────────
        ColoredBox(
          color: const Color(0xFFF5F6FA),
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                // Hero image
                _PoojaHero(topPad: topPad, onSearchTap: _triggerSearch),
                // Pooja list
                ValueListenableBuilder<bool>(
                  valueListenable: PoojaService.isLoading,
                  builder: (context, loading, _) {
                    if (loading && PoojaService.poojas.value.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                            child: CircularProgressIndicator.adaptive()),
                      );
                    }
                    return ValueListenableBuilder<List<PoojaModel>>(
                      valueListenable: PoojaService.poojas,
                      builder: (context, poojas, _) {
                        final filtered = _searchQuery.isEmpty
                            ? poojas
                            : poojas
                                .where((p) => p.name
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()))
                                .toList();
                        if (filtered.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: ValueListenableBuilder<String?>(
                              valueListenable: PoojaService.error,
                              builder: (context, err, _) => Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cloud_off_outlined,
                                        size: 48, color: AppColors.grey500),
                                    const SizedBox(height: 12),
                                    Text(AppL10n.s.couldNotLoadPoojas,
                                        style: const TextStyle(
                                            color: AppColors.grey700)),
                                    if (err != null) ...[
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32),
                                        child: Text(err,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey500),
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () =>
                                          PoojaService.load(force: true),
                                      child: Text(AppL10n.s.retry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                              16, 8, 16, bottomPad + 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _PoojaCard(pooja: filtered[i]),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Sticky title bar (appears on scroll) ────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          top: _showBar ? 0 : -(topPad + kToolbarHeight),
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
                    offset: Offset(0, 3)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: topPad),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: Icon(
                        _searching
                            ? Icons.arrow_back
                            : Icons.menu_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _searching
                          ? _closeSearch
                          : () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: _searching
                        ? SizeTransition(
                            sizeFactor: _searchExpand,
                            axis: Axis.horizontal,
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              onChanged: (q) =>
                                  setState(() => _searchQuery = q),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: AppL10n.s.searchPoojasHint,
                                hintStyle: const TextStyle(
                                    color: Colors.white60, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        : Text(
                            AppL10n.s.poojaVidhiLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      _searching ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: _searching ? _closeSearch : _openSearch,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero image section ────────────────────────────────────────────────────────

class _PoojaHero extends StatelessWidget {
  final double topPad;
  final VoidCallback? onSearchTap;
  const _PoojaHero({required this.topPad, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: topPad + _PoojaScreenState._heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: 'https://app.trimbakeshwarpoojavidhi.in/static/images/pooja_hero.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.3, 0),
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
          // Gradient overlay — dark at bottom, clear at top
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xEE000000),
                  Color(0x66000000),
                  Color(0x11000000),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.5, 1.0],
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
                  icon: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),
          // Search icon
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 26),
                onPressed: onSearchTap,
              ),
            ),
          ),
          // Title at bottom
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppL10n.s.poojaVidhiLabel,
                  style: const TextStyle(
                    fontFamily: 'Samarkan',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppL10n.s.poojaHeroSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Samarkan',
                    fontSize: 13,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _heroBadge(Icons.auto_awesome_rounded,
                        AppL10n.s.heroBadge('Vedic Rituals')),
                    _heroBadge(Icons.self_improvement_rounded,
                        AppL10n.s.heroBadge('Ancestral Liberation')),
                    _heroBadge(Icons.temple_hindu_rounded,
                        AppL10n.s.heroBadge('12th Jyotirlinga')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Sanskrit symbol glyphs used as decorative overlays ───────────────────────

const Map<String, String> _poojaSymbol = {
  'Narayan Nagbali':    '☽',
  'Kalsarpa Shanti':   '🐍',
  'Tripindi Shraddha': '🪔',
  'Rudra Abhishek':    '𑁍',
  'Mahamrityunjay Jaap': 'ॐ',
  'Vastu Shanti':      '卐',
  'Laghu Rudra Pooja': '𑁍',
  'Navgrah Shanti':    '✦',
};

final Map<String, String> _poojaImage = {
  'Narayan Nagbali':     AppImages.narayanNagbali,
  'Kalsarpa Shanti':    AppImages.kalsarpaShanti,
  'Tripindi Shraddha':  AppImages.tripindi,
  'Rudra Abhishek':     AppImages.rudraAbhishek,
  'Mahamrityunjay Jaap': AppImages.mahamrityunjayJaap,
  'Laghu Rudra Pooja':  AppImages.laghuRudra,
  'Navgrah Shanti':     AppImages.navgrahShanti,
};

// ── Card ──────────────────────────────────────────────────────────────────────

class _PoojaCard extends StatelessWidget {
  final PoojaModel pooja;

  const _PoojaCard({required this.pooja});

  void _openDetail(BuildContext context) {
    PoojaService.load(force: true, silent: true);
    Navigator.push(
      context,
      fadeSlideRoute((_) => PoojaDetailScreen(pooja: pooja)),
    );
  }

  void _openMuhurta(BuildContext context) {
    showMuhurtaSheet(context, pooja.muhurtaDates, pooja.color);
  }

  void _bookNow(BuildContext context) {
    if (AuthService.isLoggedIn) {
      Navigator.push(
        context,
        fadeSlideRoute((_) => BookingScreen(selectedPooja: pooja.name)),
      );
    } else {
      Navigator.push(
        context,
        fadeSlideRoute(
          (_) => LoginScreen(
            onLoginSuccess: (_) => BookingScreen(selectedPooja: pooja.name),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = pooja.color;
    final symbol = _poojaSymbol[pooja.name] ?? 'ॐ';
    final imagePath = _poojaImage[pooja.name];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: image or gradient band ───────────────────────────
            GestureDetector(
              onTap: () => _openDetail(context),
              child: SizedBox(
              height: imagePath != null ? 140 : 46,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imagePath != null)
                    AppImage(src: imagePath, fit: BoxFit.cover, fallbackColor: color)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  // Gradient scrim for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.82),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Symbol watermark
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 72,
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 1,
                      ),
                    ),
                  ),
                  // Name + chips at bottom — single full-width pill
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppL10n.s.poojaName(pooja.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _chip(Icons.schedule_rounded, AppL10n.s.poojaDuration(pooja.duration)),
                            const SizedBox(width: 8),
                            _boldChip('${pooja.pricePerPerson}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),

            // ── Description ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Text(
                AppL10n.s.poojaDesc(pooja.name).isNotEmpty
                    ? AppL10n.s.poojaDesc(pooja.name)
                    : pooja.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey700,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
              indent: 18,
              endIndent: 18,
            ),

            // ── Action buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ActionButton(
                        label: AppL10n.s.infoLabel,
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF1565C0),
                        filled: false,
                        onTap: () => _openDetail(context),
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: AppL10n.s.muhurtaLabel,
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF1565C0),
                        filled: false,
                        onTap: () => _openMuhurta(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionButton(
                        label: AppL10n.s.bookNow,
                        icon: Icons.bookmark_add_rounded,
                        color: color,
                        filled: true,
                        onTap: () => _bookNow(context),
                        price: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _boldChip(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.currency_rupee_rounded, size: 13, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final int? price;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = filled ? Colors.white : color;
    if (filled) {
      return Expanded(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(9),
              splashColor: Colors.white.withValues(alpha: 0.18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (price != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          splashColor: Colors.white.withValues(alpha: 0.18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.2,
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
