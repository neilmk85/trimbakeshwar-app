import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_l10n.dart';
import '../constants/constants.dart';
import '../utils/app_images.dart';
import '../utils/utils.dart';
import '../widgets/app_image.dart';
import '../services/settings_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _spinKey = GlobalKey<_FeedbackBannerState>();
  final _scroll  = ScrollController();
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      const threshold = 260.0;
      final opacity = ((_scroll.offset - threshold) / 80).clamp(0.0, 1.0);
      if ((_scroll.offset > 0) && _scroll.position.isScrollingNotifier.value) {
        _spinKey.currentState?.spin();
      }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          ColoredBox(
            color: const Color(0xFFF5F6FA),
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  const _HeroSection(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _ContactInfoCard(),
                  ),
                  const SizedBox(height: 28),
                  const _ConnectSection(),
                  const SizedBox(height: 28),
                  const _WebsiteLinkSection(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _FeedbackBanner(key: _spinKey),
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _MapSection(),
                  ),
                  const SafeArea(top: false, child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
          // Collapsing title bar
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
                      AppColors.primaryDark.withValues(alpha: _titleOpacity),
                      AppColors.primaryMedium.withValues(alpha: _titleOpacity),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                          AppL10n.s.contactTitle,
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
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            src: AppImages.trimbakeshwarTemple,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0x88000000),
                  Color(0xAA000000),
                  Color(0xFFF5F6FA),
                ],
              ),
            ),
          ),
          // Drawer menu button
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
          Padding(
            padding: EdgeInsets.only(top: topPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔱', style: TextStyle(fontSize: 38, height: 1)),
                const SizedBox(height: 6),
                _ornament(),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppL10n.s.gurujiNameLocalized,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 2.0,
                      shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppL10n.s.gurujiLabel,
                  style: const TextStyle(
                    color: Color(0xFFC9A035),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 5.0,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                  ),
                ),
                const SizedBox(height: 4),
                _ornament(),
                const SizedBox(height: 14),
                Text(
                  AppL10n.s.contactHeroSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13.5, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ornament() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 32,
              height: 1,
              color: const Color(0xFFC9A035).withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          const Text('ॐ',
              style: TextStyle(color: Color(0xFFC9A035), fontSize: 13, height: 1)),
          const SizedBox(width: 8),
          Container(
              width: 32,
              height: 1,
              color: const Color(0xFFC9A035).withValues(alpha: 0.7)),
        ],
      );
}

// ── Contact Info Card ─────────────────────────────────────────────────────────

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _PhoneRow(
            label: AppL10n.s.phoneLabel,
            value: AppStrings.phoneDisplay,
            onCall: () => UrlHelper.call(AppStrings.phoneNumber),
            onWhatsApp: () => UrlHelper.launch(AppStrings.whatsappUrl),
          ),
          _divider(),
          _PhoneRow(
            label: AppL10n.s.phoneLabel,
            value: AppStrings.phoneDisplay2,
            onCall: () => UrlHelper.call(AppStrings.phoneNumber2),
          ),
          _divider(),
          _ContactRow(
            icon: Icons.location_on_rounded,
            color: const Color(0xFF212121),
            label: AppL10n.s.addressLabel,
            value: AppL10n.s.gurujiLocation,
            onTap: () => UrlHelper.launch(AppStrings.mapsUrl),
          ),
          _divider(),
          _ContactRow(
            icon: Icons.email_rounded,
            color: const Color(0xFF212121),
            label: AppL10n.s.emailLabel,
            value: AppStrings.email,
            onTap: () => UrlHelper.sendEmail(AppStrings.email),
          ),
          _divider(),
          _ContactRow(
            icon: Icons.access_time_rounded,
            color: const Color(0xFF212121),
            label: AppL10n.s.workingHours,
            value: AppL10n.s.workingHoursValue,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 0.5, indent: 70, endIndent: 16, color: Color(0xFFEEEEEE));
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 3),
                  Text(value,
                      style: const TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF1565C0), size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCall;
  final VoidCallback? onWhatsApp;

  const _PhoneRow({
    required this.label,
    required this.value,
    required this.onCall,
    this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCall,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.phone_rounded, color: Color(0xFF212121), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xFF212121),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(value,
                          style: const TextStyle(
                              color: Color(0xFF616161),
                              fontSize: 13.5,
                              height: 1.45,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 20),
                      if (onWhatsApp != null)
                        GestureDetector(
                          onTap: onWhatsApp,
                          child: const FaIcon(FontAwesomeIcons.whatsapp,
                              color: Color(0xFF25D366), size: 17),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF1565C0), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Connect With Us ───────────────────────────────────────────────────────────

class _ConnectSection extends StatefulWidget {
  const _ConnectSection();

  @override
  State<_ConnectSection> createState() => _ConnectSectionState();
}

class _ConnectSectionState extends State<_ConnectSection> {
  late Future<SocialMediaLinks?> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = SettingsService.getSocialMediaLinks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialMediaLinks?>(
      future: _linksFuture,
      builder: (context, snapshot) {
        final links = snapshot.data;
        // Fallback to app strings if API fails
        final facebookUrl = links?.facebook.isNotEmpty == true ? links!.facebook : AppStrings.facebookUrl;
        final instagramUrl = links?.instagram.isNotEmpty == true ? links!.instagram : AppStrings.instagramUrl;
        final youtubeUrl = links?.youtube.isNotEmpty == true ? links!.youtube : AppStrings.youtubeUrl;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 40, height: 1, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(width: 12),
                Text(AppL10n.s.connectWithUs,
                    style: const TextStyle(
                        color: AppColors.navyDeep,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
                const SizedBox(width: 12),
                Container(
                    width: 40, height: 1, color: AppColors.primary.withValues(alpha: 0.3)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialIcon(
                  faIcon: FontAwesomeIcons.facebook,
                  color: AppColors.facebook,
                  url: facebookUrl,
                ),
                _SocialIcon(
                  faIcon: FontAwesomeIcons.instagram,
                  color: AppColors.instagram,
                  url: instagramUrl,
                ),
                _SocialIcon(
                  faIcon: FontAwesomeIcons.youtube,
                  color: AppColors.youtube,
                  url: youtubeUrl,
                ),
                _SocialIcon(
                  faIcon: FontAwesomeIcons.whatsapp,
                  color: AppColors.whatsapp,
                  url: AppStrings.whatsappUrl,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final FaIconData faIcon;
  final Color color;
  final String url;

  const _SocialIcon(
      {required this.faIcon, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () => UrlHelper.launch(url),
        child: FaIcon(faIcon, color: color, size: 30),
      ),
    );
  }
}

// ── Feedback Banner ───────────────────────────────────────────────────────────

class _FeedbackBanner extends StatefulWidget {
  const _FeedbackBanner({super.key});

  @override
  State<_FeedbackBanner> createState() => _FeedbackBannerState();
}

class _FeedbackBannerState extends State<_FeedbackBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  void spin() {
    if (_ctrl.isAnimating) return;
    _ctrl.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _ctrl.forward(from: 0);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rotating multicolored Google G
          RotationTransition(
                turns: CurvedAnimation(parent: _ctrl, curve: Curves.decelerate),
              child: ShaderMask(
                shaderCallback: (bounds) => const SweepGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFFEA4335),
                    Color(0xFFFBBC05),
                    Color(0xFF34A853),
                    Color(0xFF4285F4),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const FaIcon(FontAwesomeIcons.google,
                    size: 30, color: Colors.white),
              ),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.s.enjoyedService,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep)),
                const SizedBox(height: 3),
                Text(AppL10n.s.shareExperience,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Button
          GestureDetector(
            onTap: () => UrlHelper.launch(AppStrings.googleReviewUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEA4335),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA4335).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text(AppL10n.s.googleReview,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map Section ───────────────────────────────────────────────────────────────

const _gurujiLocation = LatLng(19.9373, 73.5310); // Trimbakeshwar

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UrlHelper.launch(AppStrings.mapsUrl),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live map tile
          SizedBox(
            height: 200,
            child: IgnorePointer(child: FlutterMap(
              options: const MapOptions(
                initialCenter: _gurujiLocation,
                initialZoom: 15,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.trimbakeshwar.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _gurujiLocation,
                      width: 48,
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.temple_hindu_rounded,
                                color: Colors.white, size: 18),
                          ),
                          // Pin tail
                          Container(
                            width: 2,
                            height: 8,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),  // IgnorePointer + FlutterMap
          ),
          // Address & button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(Icons.place_rounded, AppL10n.s.gurujiLocation),
                const SizedBox(height: 8),
                _row(Icons.access_time_rounded, AppL10n.s.workingHoursValue),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => UrlHelper.launch(AppStrings.mapsUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(AppL10n.s.openInGoogleMaps),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),  // Container
    );    // GestureDetector
  }

  Widget _row(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF37474F),
                    height: 1.5)),
          ),
        ],
      );
}

// ── Website Link Section ──────────────────────────────────────────────────────

class _WebsiteLinkSection extends StatefulWidget {
  const _WebsiteLinkSection();

  @override
  State<_WebsiteLinkSection> createState() => _WebsiteLinkSectionState();
}

class _WebsiteLinkSectionState extends State<_WebsiteLinkSection> {
  late Future<SocialMediaLinks?> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = SettingsService.getSocialMediaLinks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialMediaLinks?>(
      future: _linksFuture,
      builder: (context, snapshot) {
        final websiteUrl = snapshot.data?.website ?? AppStrings.websiteUrl;

        if (websiteUrl.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => UrlHelper.launch(websiteUrl),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.language_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppL10n.s.visitOurWebsite,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          websiteUrl.replaceFirst('https://', '').replaceFirst('http://', ''),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey500,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
