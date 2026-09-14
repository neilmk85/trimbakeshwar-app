import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../constants/app_l10n.dart';
import '../models/pooja_model.dart';
import '../services/pooja_service.dart';
import '../utils/url_helper.dart';
import '../utils/app_route.dart';
import '../utils/app_images.dart';
import '../widgets/app_image.dart';

import 'pooja_detail_screen.dart';

class GurujiScreen extends StatefulWidget {
  const GurujiScreen({super.key});

  @override
  State<GurujiScreen> createState() => _GurujiScreenState();
}

class _GurujiScreenState extends State<GurujiScreen> {
  final _scroll = ScrollController();
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    PoojaService.load();
    _scroll.addListener(() {
      final opacity = ((_scroll.offset - 220) / 80).clamp(0.0, 1.0);
      if ((opacity - _titleOpacity).abs() > 0.01) {
        setState(() => _titleOpacity = opacity);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scroll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(context: context),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AboutCard(),
                    const SizedBox(height: 12),
                    _ExpertiseCard(context: context),
                    const SizedBox(height: 12),
                    _DirectionsCard(),
                    const SizedBox(height: 100), // nav bar clearance
                  ],
                ),
              ),
            ],
          ),
        ),
        // Sticky title bar — fades in as hero scrolls away
        Positioned(
          top: 0, left: 0, right: 0,
          child: AnimatedOpacity(
            opacity: _titleOpacity,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: topPad + kToolbarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _cosmicDeep.withValues(alpha: _titleOpacity),
                    _cosmicMid.withValues(alpha: _titleOpacity),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
                        AppL10n.s.gurujiNameLocalized,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Fuzzy name match: "Laghu Rudra" matches "Laghu Rudra Pooja", etc.
bool _poojaNameMatches(String a, String b) {
  final x = a.toLowerCase().trim();
  final y = b.toLowerCase().trim();
  return x == y || x.startsWith(y) || y.startsWith(x);
}

// ── Cosmic blue palette ───────────────────────────────────────────────────────

const _cosmicDeep       = Color(0xFF050B1E);   // near-black deep space
const _cosmicDark       = Color(0xFF0A1A4A);   // deep navy
const _cosmicMid        = Color(0xFF0D47A1);   // cosmic blue
const _cosmicBlue       = Color(0xFF1565C0);   // primary blue
const _nebulaViolet     = Color(0xFF4527A0);   // deep indigo glow
const _starBlue         = Color(0xFF64B5F6);   // light blue star
const _cosmicGold       = Color(0xFFFFD54F);   // warm gold
const _cosmicGoldBright = Color(0xFFFFF176);   // bright gold

// ── Profile Header (Cosmic Hero) ──────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final BuildContext context;
  const _ProfileHeader({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cosmicDeep, _cosmicDark, _cosmicMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Nebula glow — top-left ───────────────────────────────────────────
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _nebulaViolet.withValues(alpha: 0.28),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // ── Nebula glow — bottom-right ───────────────────────────────────────
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _cosmicBlue.withValues(alpha: 0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // ── Star particles ────────────────────────────────────────────────────
          const Positioned(top: 72,  right: 44,  child: _StarDot(3.5)),
          const Positioned(top: 130, right: 95,  child: _StarDot(2.0)),
          const Positioned(top: 55,  right: 130, child: _StarDot(4.0)),
          const Positioned(top: 100, left: 28,   child: _StarDot(2.5)),
          const Positioned(top: 175, left: 55,   child: _StarDot(3.0)),
          const Positioned(top: 210, right: 60,  child: _StarDot(2.0)),
          const Positioned(top: 88,  left: 95,   child: _StarDot(1.8)),
          // ── Cosmic watermark ─────────────────────────────────────────────────
          Positioned(
            right: -24, bottom: -28,
            child: Text(
              'ॐ',
              style: TextStyle(
                fontSize: 200,
                color: Colors.white.withValues(alpha: 0.025),
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          // ── Bottom shimmer bar ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  _starBlue,
                  _cosmicGold,
                  _starBlue,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // ── Floating menu button ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0,
            child: SafeArea(
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),
          // ── Main content ──────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
              child: Column(
                children: [
                  // Avatar with cosmic glow
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _starBlue.withValues(alpha: 0.7),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _cosmicBlue.withValues(alpha: 0.65),
                          blurRadius: 32, spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: _nebulaViolet.withValues(alpha: 0.3),
                          blurRadius: 52, spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: _starBlue.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        width: 110, height: 110,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_cosmicBlue, _nebulaViolet],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Sanskrit subtitle
                  Text(
                    'ज्योतिर्लिंग पुजारी',
                    style: TextStyle(
                      fontSize: 12,
                      color: _cosmicGold.withValues(alpha: 0.9),
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppL10n.s.gurujiNameLocalized,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppL10n.s.gurujiRole,
                    style: TextStyle(
                      fontSize: 13,
                      color: _starBlue.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.white.withValues(alpha: 0.55)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            AppL10n.s.gurujiLocation,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.55)),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Social icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIcon(
                        faIcon: FontAwesomeIcons.instagram,
                        tooltip: 'Instagram',
                        onTap: () => UrlHelper.launch(AppStrings.instagramUrl),
                      ),
                      const SizedBox(width: 12),
                      _SocialIcon(
                        faIcon: FontAwesomeIcons.facebook,
                        tooltip: 'Facebook',
                        onTap: () => UrlHelper.launch(AppStrings.facebookUrl),
                      ),
                      const SizedBox(width: 12),
                      _SocialIcon(
                        faIcon: FontAwesomeIcons.youtube,
                        tooltip: 'YouTube',
                        onTap: () => UrlHelper.launch(AppStrings.youtubeUrl),
                      ),
                      const SizedBox(width: 12),
                      _SocialIcon(
                        materialIcon: Icons.location_on_rounded,
                        tooltip: 'Google Maps',
                        onTap: () => UrlHelper.launch(AppStrings.mapsUrl),
                      ),
                      const SizedBox(width: 12),
                      _SocialIcon(
                        materialIcon: Icons.rate_review_rounded,
                        tooltip: 'Google Review',
                        onTap: () => UrlHelper.launch(AppStrings.googleReviewUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Cosmic pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CosmicPill(
                          icon: Icons.auto_awesome_rounded,
                          label: AppL10n.s.gurujiExpPill),
                      const SizedBox(width: 10),
                      _CosmicPill(
                          icon: Icons.temple_hindu_rounded,
                          label: AppL10n.s.trimbakeshwar),
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

class _StarDot extends StatelessWidget {
  final double size;
  const _StarDot(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.65),
        boxShadow: [
          BoxShadow(
            color: _starBlue.withValues(alpha: 0.8),
            blurRadius: size * 2,
          ),
        ],
      ),
    );
  }
}

class _CosmicPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CosmicPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: _cosmicGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _cosmicGoldBright, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: _cosmicGoldBright,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social / Contact Icon (transparent circle) ───────────────────────────────
// Pass either a FontAwesome [icon] or a Material [materialIcon] — not both.

class _SocialIcon extends StatelessWidget {
  final FaIconData? faIcon;
  final IconData? materialIcon;
  final String? tooltip;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.onTap,
    this.faIcon,
    this.materialIcon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _starBlue.withValues(alpha: 0.22),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: materialIcon != null
              ? Icon(materialIcon, size: 20, color: Colors.white)
              : FaIcon(faIcon!, size: 18, color: Colors.white),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: BoxDecoration(
          color: _cosmicDark.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        preferBelow: false,
        child: child,
      );
    }
    return child;
  }
}

// ── About Card ────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppL10n.s.gurujiNameLocalized,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => UrlHelper.call(AppStrings.phoneNumber),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.phone_rounded,
                      size: 16, color: Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => UrlHelper.openWhatsApp(AppStrings.phoneNumber),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.whatsapp.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.whatsapp.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        size: 15, color: AppColors.whatsapp),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppL10n.s.gurujiAboutText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey700,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlights Card ───────────────────────────────────────────────────────────

// ── Expertise Card ────────────────────────────────────────────────────────────

class _ExpertiseCard extends StatelessWidget {
  final BuildContext context;
  const _ExpertiseCard({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                AppL10n.s.poojaVidhiLabel,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<PoojaModel>>(
            valueListenable: PoojaService.poojas,
            builder: (context, poojas, _) {
              final items = poojas.isNotEmpty ? poojas : <PoojaModel>[];
              if (items.isEmpty) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: AppData.gurujiExpertise.length,
                  itemBuilder: (_, i) => _StaticPoojaCard(
                    label: AppL10n.s.expertiseName(AppData.gurujiExpertise[i]),
                    onTap: () async {
                      final name = AppData.gurujiExpertise[i];
                      await PoojaService.load();

                      // Try live server data first
                      PoojaModel? match = PoojaService.poojas.value
                          .where((p) => _poojaNameMatches(p.name, name))
                          .firstOrNull;

                      // Fallback: build from local AppData
                      if (match == null) {
                        final local = AppData.poojas
                            .where((p) => _poojaNameMatches(
                                p['name'] as String? ?? '', name))
                            .firstOrNull;
                        if (local != null) {
                          match = PoojaModel.fromAppData(local);
                        }
                      }

                      if (match != null && context.mounted) {
                        Navigator.push(
                          context,
                          fadeSlideRoute((_) => PoojaDetailScreen(pooja: match!)),
                        );
                      }
                    },
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _PoojaCard(
                  pooja: items[i],
                  onTap: () => Navigator.push(
                    context,
                    fadeSlideRoute((_) => PoojaDetailScreen(pooja: items[i])),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

final _poojaImageMap = <String, String>{
  'Narayan Nagbali':     AppImages.narayanNagbali,
  'Kalsarpa Shanti':    AppImages.kalsarpaShanti,
  'Tripindi Shraddha':  AppImages.tripindi,
  'Rudra Abhishek':     AppImages.rudraAbhishek,
  'Mahamrityunjay Jaap': AppImages.mahamrityunjayJaap,
  'Laghu Rudra Pooja':  AppImages.laghuRudra,
  'Navgrah Shanti':     AppImages.navgrahShanti,
  'Vastu Shanti':       AppImages.vastuShanti,
};

const _poojaSymbolMap = <String, String>{
  'Narayan Nagbali':     '☽',
  'Kalsarpa Shanti':    '🐍',
  'Tripindi Shraddha':  '🪔',
  'Rudra Abhishek':     '𑁍',
  'Mahamrityunjay Jaap':'ॐ',
  'Vastu Shanti':       '卐',
  'Laghu Rudra Pooja':  '𑁍',
  'Navgrah Shanti':     '✦',
};

class _PoojaCard extends StatelessWidget {
  final PoojaModel pooja;
  final VoidCallback onTap;
  const _PoojaCard({required this.pooja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = pooja.color;
    final symbol = _poojaSymbolMap[pooja.name] ?? 'ॐ';
    final imagePath = _poojaImageMap[pooja.name];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Background
              Positioned.fill(
                child: imagePath != null
                    ? AppImage(src: imagePath, fit: BoxFit.cover, fallbackColor: color)
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              // Dark scrim
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x22000000), Color(0x88000000), Color(0xEE000000)],
                      stops: [0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Symbol watermark
              Positioned(
                right: -4, top: -4,
                child: Text(symbol,
                    style: TextStyle(
                        fontSize: 60,
                        color: Colors.white.withValues(alpha: 0.07),
                        height: 1)),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Name chip at top
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          AppL10n.s.poojaName(pooja.name),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pooja.duration.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _chip(Icons.schedule_rounded, AppL10n.s.poojaDuration(pooja.duration)),
                      ],
                      const Spacer(),
                      // Book Now + price at bottom
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        width: 1.2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bookmark_add_rounded,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(AppL10n.s.bookNow,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                      if (pooja.pricePerPerson > 0) ...[
                                        const SizedBox(width: 4),
                                        Text('· ₹${pooja.pricePerPerson}',
                                            style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ],
                                  ),
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

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StaticPoojaCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _StaticPoojaCard({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey800,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Book Now button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D01E8), Color(0xFF3136D5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppL10n.s.bookNow),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Directions Card ───────────────────────────────────────────────────────────

class _DirectionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => UrlHelper.launch(AppStrings.mapsUrl),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppL10n.s.directionsLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Gurukrupa Niwas, opposite Niranjani Akhada,\nShri Swami Samartha Ring Road, Trimbakeshwar, Nashik - 422212',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

