import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_l10n.dart';
import '../services/language_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';

String _t(String en, String hi) => LanguageService.isHindi.value ? hi : en;

// ── Palette (single-tone navy / slate) ────────────────────────────────────────
const _navy = Color(0xFF0D2137);
const _navyMid = Color(0xFF163350);
const _accent = Color(0xFF1565C0);
const _accentLight = Color(0xFFE8F0FE);
const _textPrimary = Color(0xFF0D2137);
const _textSecondary = Color(0xFF4A6080);
const _divider = Color(0xFFDDE4EE);
const _surface = Color(0xFFF4F7FC);

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderAnim;
  final _scroll = ScrollController();
  bool _barCollapsed = false;

  // Hero collapses over (expandedHeight 148 – kToolbarHeight 56) = 92px.
  // Migrate the pill to the app bar once scrolling begins.
  static const _collapseAt = 30.0;

  @override
  void initState() {
    super.initState();
    _borderAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _scroll.addListener(() {
      final c = _scroll.offset > _collapseAt;
      if (c != _barCollapsed) setState(() => _barCollapsed = c);
    });
  }

  @override
  void dispose() {
    _borderAnim.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onTap: (i) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: i)),
          (_) => false,
        ),
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    icon: Icons.auto_awesome_rounded,
                    title: AppL10n.s.poojaBookingSection,
                    items: [
                      _Item(
                        icon: Icons.calendar_today_rounded,
                        text: _t(
                          'Book your pooja at least 2–3 days in advance, especially for rituals like Narayan Nagbali or Kalsarpa Shanti, which require preparation.',
                          'पूजा कम से कम 2-3 दिन पहले बुक करें, विशेषकर नारायण नागबली या कालसर्प शांति जैसे अनुष्ठानों के लिए, जिनमें तैयारी आवश्यक है।',
                        ),
                      ),
                      _Item(
                        icon: Icons.person_rounded,
                        text: _t(
                          'Provide accurate details of all participants — full names, gotra, and birth date — as these are chanted during the ritual.',
                          'सभी प्रतिभागियों का सही विवरण दें — पूरा नाम, गोत्र और जन्मतिथि — ये अनुष्ठान के दौरान पढ़े जाते हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.no_meals_rounded,
                        text: _t(
                          'Observe a fast on the day of the pooja until the ritual is complete. Avoid non-vegetarian food for at least one day prior.',
                          'पूजा के दिन अनुष्ठान पूर्ण होने तक उपवास करें। कम से कम एक दिन पहले से मांसाहारी भोजन से बचें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.shower_rounded,
                        text: _t(
                          'Take a bath and wear clean, traditional clothing before attending the pooja ceremony.',
                          'पूजा में भाग लेने से पहले स्नान करें और साफ, परंपरागत वस्त्र पहनें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.receipt_long_rounded,
                        text: _t(
                          'Keep your booking confirmation ready. You will receive it via SMS/email after payment is confirmed.',
                          'अपनी बुकिंग पुष्टि तैयार रखें। भुगतान की पुष्टि के बाद आपको SMS/ईमेल द्वारा प्राप्त होगी।',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.checkroom_rounded,
                    title: AppL10n.s.clothesSection,
                    items: [
                      _Item(
                        icon: Icons.man_rounded,
                        text: _t(
                          'Men should wear a white or off-white dhoti or kurta-pyjama. Avoid dark-coloured clothing on the day of the pooja.',
                          'पुरुषों को सफेद या ऑफ-व्हाइट धोती या कुर्ता-पाजामा पहनना चाहिए। पूजा के दिन गहरे रंग के कपड़े न पहनें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.woman_rounded,
                        text: _t(
                          'Women should wear a white or yellow saree or salwar-kameez. Avoid black or dark-coloured attire.',
                          'महिलाओं को सफेद या पीली साड़ी या सलवार-कमीज पहनना चाहिए। काले या गहरे रंग के वस्त्र न पहनें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.dry_cleaning_rounded,
                        text: _t(
                          'Clothes must be freshly washed and worn specifically for the pooja. Do not wear the same clothes worn during travel.',
                          'वस्त्र ताज़े धुले होने चाहिए और केवल पूजा के लिए पहने जाने चाहिए। यात्रा में पहने कपड़े न पहनें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.local_florist_rounded,
                        text: _t(
                          'Bring fresh flowers — white or yellow are preferred. Jasmine, marigold, or lotus are most auspicious for Lord Shiva.',
                          'ताजे फूल लाएं — सफेद या पीले रंग उचित हैं। भगवान शिव के लिए चमेली, गेंदा या कमल सबसे शुभ हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.eco_rounded,
                        text: _t(
                          'Carry bilva (bel) leaves if available. They are highly sacred and offered directly to the Shivalinga.',
                          'यदि उपलब्ध हो तो बिल्वपत्र (बेल) लाएं। ये अत्यंत पवित्र हैं और सीधे शिवलिंग पर अर्पित किए जाते हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.spa_rounded,
                        text: _t(
                          'Guruji provides all ritual samagri (materials) as part of the booked pooja. You may additionally bring coconut, fruits, and a small amount of jaggery for offerings.',
                          'गुरुजी बुकिंग की पूजा का संपूर्ण सामान प्रदान करते हैं। आप अतिरिक्त रूप से नारियल, फल और थोड़ा गुड़ ला सकते हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.currency_rupee_rounded,
                        text: _t(
                          'Keep cash ready for dakshina. Small denominations are preferred. This is offered to the priest at the end of the ceremony.',
                          'दक्षिणा के लिए नकद तैयार रखें। छोटे नोट उचित हैं। यह समारोह के अंत में पुजारी को अर्पित किया जाता है।',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCardGrouped(
                    icon: Icons.no_meals_rounded,
                    title: AppL10n.s.foodFastingSection,
                    groups: [
                      _Group(
                        subTitle: AppL10n.s.beforePoojaGroup,
                        items: [
                          _Item(
                            icon: Icons.wb_sunny_outlined,
                            text: _t(
                              'Observe a fast from sunrise on the day of the pooja. If a full fast is not possible, eat only sattvic food — fruits, milk, or light boiled meals.',
                              'पूजा के दिन सूर्योदय से उपवास करें। यदि पूर्ण उपवास संभव न हो, केवल सात्विक आहार लें — फल, दूध या हल्का उबला भोजन।',
                            ),
                          ),
                          _Item(
                            icon: Icons.no_meals_rounded,
                            text: _t(
                              'Avoid non-vegetarian food, eggs, and onion-garlic for at least one day before the pooja.',
                              'पूजा से कम से कम एक दिन पहले मांसाहार, अंडे और प्याज-लहसुन से बचें।',
                            ),
                          ),
                          _Item(
                            icon: Icons.no_drinks_rounded,
                            text: _t(
                              'Avoid alcohol and tobacco for a minimum of three days before the ceremony. These are considered highly inauspicious.',
                              'समारोह से कम से कम तीन दिन पहले मद्य और तंबाकू से बचें। इन्हें अत्यंत अशुभ माना जाता है।',
                            ),
                          ),
                          _Item(
                            icon: Icons.nightlight_round,
                            text: _t(
                              'For rituals like Narayan Nagbali or Tripindi Shraddha, a fast from the previous evening (after sunset) is recommended.',
                              'नारायण नागबली या त्रिपिंडी श्राद्ध जैसे अनुष्ठानों के लिए, पिछली शाम (सूर्यास्त के बाद) से उपवास की सलाह दी जाती है।',
                            ),
                          ),
                        ],
                      ),
                      _Group(
                        subTitle: AppL10n.s.afterPoojaGroup,
                        items: [
                          _Item(
                            icon: Icons.volunteer_activism_rounded,
                            text: _t(
                              'Break your fast with the prasad received from the pooja. Accept it with both hands as a sacred blessing.',
                              'पूजा से प्राप्त प्रसाद से उपवास तोड़ें। इसे दोनों हाथों से पवित्र आशीर्वाद के रूप में स्वीकार करें।',
                            ),
                          ),
                          _Item(
                            icon: Icons.rice_bowl_rounded,
                            text: _t(
                              'Have a simple vegetarian meal after the ceremony. Avoid heavy or oily food immediately after the ritual.',
                              'समारोह के बाद सरल शाकाहारी भोजन करें। अनुष्ठान के तुरंत बाद भारी या तैलीय भोजन से बचें।',
                            ),
                          ),
                          _Item(
                            icon: Icons.grass_rounded,
                            text: _t(
                              'Continue with pure vegetarian food for the remainder of the day. This helps maintain the sanctity of the ritual.',
                              'दिन के शेष समय शुद्ध शाकाहारी भोजन जारी रखें। यह अनुष्ठान की पवित्रता बनाए रखने में मदद करता है।',
                            ),
                          ),
                          _Item(
                            icon: Icons.water_drop_rounded,
                            text: _t(
                              "Drink plenty of water and stay hydrated, especially if you observed a full day's fast.",
                              'भरपूर पानी पिएं और हाइड्रेटेड रहें, विशेषकर यदि आपने पूरे दिन उपवास किया हो।',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.spa_rounded,
                    title: AppL10n.s.spiritualSection,
                    items: [
                      _Item(
                        icon: Icons.volunteer_activism_rounded,
                        text: _t(
                          'Approach the Lord with a pure heart and sincere devotion. The rituals are most effective when performed with complete faith.',
                          'भगवान के पास शुद्ध हृदय और सच्ची भक्ति से जाएं। अनुष्ठान पूर्ण आस्था के साथ करने पर सबसे प्रभावी होते हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.self_improvement_rounded,
                        text: _t(
                          'Chant "Om Namah Shivaya" or any Shiva mantra during the wait in queue. It prepares the mind and invokes positive energy.',
                          '"ॐ नमः शिवाय" या कोई शिव मंत्र प्रतीक्षा के दौरान जपें। यह मन को तैयार करता है और सकारात्मक ऊर्जा जगाता है।',
                        ),
                      ),
                      _Item(
                        icon: Icons.no_drinks_rounded,
                        text: _t(
                          'Avoid consuming alcohol or tobacco on the day of your visit. These are considered inauspicious near the temple.',
                          'दर्शन के दिन मद्य या तंबाकू का सेवन न करें। मंदिर के निकट इन्हें अशुभ माना जाता है।',
                        ),
                      ),
                      _Item(
                        icon: Icons.favorite_border_rounded,
                        text: _t(
                          'Be respectful to fellow devotees and temple staff. Queue discipline and mutual respect are part of the spiritual practice.',
                          'साथी भक्तों और मंदिर कर्मचारियों का सम्मान करें। कतार अनुशासन और पारस्परिक सम्मान आध्यात्मिक अभ्यास का अंग है।',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.temple_hindu_rounded,
                    title: AppL10n.s.visitTempleSection,
                    items: [
                      _Item(
                        icon: Icons.access_time_rounded,
                        text: _t(
                          'Temple opens at 5:30 AM and closes at 9:00 PM. Arrive early to avoid long queues, especially on Mondays and festival days.',
                          'मंदिर सुबह 5:30 बजे खुलता है और रात 9:00 बजे बंद होता है। लंबी कतारों से बचने के लिए जल्दी पहुंचें, विशेषकर सोमवार और त्योहारों पर।',
                        ),
                      ),
                      _Item(
                        icon: Icons.checkroom_rounded,
                        text: _t(
                          'Traditional attire is required. Men should wear dhoti or kurta-pyjama. Women should wear saree, salwar-kameez, or any modest traditional dress.',
                          'परंपरागत वस्त्र आवश्यक हैं। पुरुष धोती या कुर्ता-पाजामा पहनें। महिलाएं साड़ी, सलवार-कमीज या कोई भी शालीन परंपरागत वस्त्र पहनें।',
                        ),
                      ),
                      _Item(
                        icon: Icons.no_photography_rounded,
                        text: _t(
                          'Photography and mobile phones are strictly prohibited inside the sanctum sanctorum.',
                          'गर्भगृह के अंदर फोटोग्राफी और मोबाइल फोन सख्त वर्जित हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.remove_shopping_cart_rounded,
                        text: _t(
                          'Leather items including belts, shoes, and bags must be left outside the temple premises.',
                          'चमड़े की वस्तुएं जैसे बेल्ट, जूते और बैग मंदिर परिसर के बाहर छोड़नी होंगी।',
                        ),
                      ),
                      _Item(
                        icon: Icons.front_hand_rounded,
                        text: _t(
                          'Maintain silence and respect near the Jyotirlinga. Avoid loud conversation or playing audio inside the temple.',
                          'ज्योतिर्लिंग के निकट मौन और आदर बनाए रखें। मंदिर के अंदर जोर से बातचीत या ऑडियो बजाने से बचें।',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.travel_explore_rounded,
                    title: AppL10n.s.gettingThereSection,
                    items: [
                      _Item(
                        icon: Icons.directions_bus_rounded,
                        text: _t(
                          'Trimbakeshwar is 28 km from Nashik. State transport buses and shared autos are available from Nashik CBS bus stand.',
                          'त्र्यंबकेश्वर नाशिक से 28 किमी दूर है। नाशिक CBS बस स्टैंड से राज्य परिवहन बसें और शेयर ऑटो उपलब्ध हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.local_parking_rounded,
                        text: _t(
                          'Paid parking is available near the temple. Two-wheelers and four-wheelers have separate designated areas.',
                          'मंदिर के पास सशुल्क पार्किंग उपलब्ध है। दोपहिया और चारपहिया वाहनों के लिए अलग-अलग क्षेत्र हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.luggage_rounded,
                        text: _t(
                          'Deposit your belongings at the cloakroom near the entrance. Lockers are available for a small fee.',
                          'प्रवेश द्वार के पास क्लोकरूम में अपना सामान जमा करें। थोड़े शुल्क में लॉकर उपलब्ध हैं।',
                        ),
                      ),
                      _Item(
                        icon: Icons.local_hospital_rounded,
                        text: _t(
                          'A first-aid post is located near the main entrance. Contact temple security in case of any emergency.',
                          'मुख्य प्रवेश द्वार के पास प्राथमिक चिकित्सा केंद्र है। किसी भी आपात स्थिति में मंदिर सुरक्षा से संपर्क करें।',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.rule_rounded,
                    title: AppL10n.s.dosDontsSection,
                    items: [
                      _Item(
                        icon: Icons.check_circle_outline_rounded,
                        text: _t(
                          'Do bow with humility and offer flowers, bilva leaves, and water with devotion.',
                          'विनम्रता से प्रणाम करें और श्रद्धापूर्वक फूल, बिल्वपत्र और जल अर्पित करें।',
                        ),
                        positive: true,
                      ),
                      _Item(
                        icon: Icons.check_circle_outline_rounded,
                        text: _t(
                          "Do listen carefully to the Guruji's instructions during the pooja ceremony.",
                          'पूजा के दौरान गुरुजी के निर्देशों को ध्यान से सुनें।',
                        ),
                        positive: true,
                      ),
                      _Item(
                        icon: Icons.check_circle_outline_rounded,
                        text: _t(
                          'Do return any prasad or sacred items given by the pandit with both hands.',
                          'पंडित द्वारा दिया गया प्रसाद या पवित्र वस्तुएं दोनों हाथों से लें।',
                        ),
                        positive: true,
                      ),
                      _Item(
                        icon: Icons.cancel_outlined,
                        text: _t(
                          "Don't touch the Shivalinga or sacred items without the priest's guidance.",
                          'पुजारी के मार्गदर्शन के बिना शिवलिंग या पवित्र वस्तुओं को न छुएं।',
                        ),
                        positive: false,
                      ),
                      _Item(
                        icon: Icons.cancel_outlined,
                        text: _t(
                          "Don't bargain with priests or temple staff over dakshina for the pooja.",
                          'पूजा की दक्षिणा के लिए पुजारियों या मंदिर कर्मचारियों से मोलभाव न करें।',
                        ),
                        positive: false,
                      ),
                      _Item(
                        icon: Icons.cancel_outlined,
                        text: _t(
                          "Don't litter within the temple complex. Use the designated bins provided.",
                          'मंदिर परिसर में कचरा न फेंकें। निर्धारित कूड़ेदान का उपयोग करें।',
                        ),
                        positive: false,
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 148,
      pinned: true,
      backgroundColor: _navy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppL10n.s.instructionsTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedBuilder(
            animation: _borderAnim,
            builder: (_, __) => _bookPoojaRainbowPill(_borderAnim.value),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, Color(0xFF1A4068), _navyMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 160,
                  color: Colors.white.withValues(alpha: 0.07),
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppL10n.s.poojaAttireSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _heroBadge(Icons.auto_awesome_rounded, AppL10n.s.sectionsCountLabel),
                      const SizedBox(width: 8),
                      _heroBadge(Icons.checklist_rounded, AppL10n.s.guidelinesCountLabel),
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

  Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookPoojaRainbowPill(double rotation) {
    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 1)),
        (_) => false,
      ),
      child: CustomPaint(
        painter: _RainbowPillPainter(rotation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 5),
              Text(
                AppL10n.s.bookPoojaLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 9),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_Item> items;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Heading inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _divider),
          // Items
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i]._buildRow(),
                  if (i < items.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: _divider,
                      indent: 56,
                      endIndent: 18,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grouped section (with sub-headings) ──────────────────────────────────────

class _Group {
  final String subTitle;
  final List<_Item> items;
  const _Group({required this.subTitle, required this.items});
}

class _SectionCardGrouped extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_Group> groups;

  const _SectionCardGrouped({
    required this.icon,
    required this.title,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Heading inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _divider),
          // Groups
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int g = 0; g < groups.length; g++) ...[
                  // Sub-heading bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _accent.withValues(alpha: 0.18)),
                    ),
                    child: Text(
                      groups[g].subTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Items
                  for (int i = 0; i < groups[g].items.length; i++) ...[
                    groups[g].items[i]._buildRow(),
                    if (i < groups[g].items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _divider,
                        indent: 56,
                        endIndent: 18,
                      ),
                  ],
                  if (g < groups.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: _divider,
                      indent: 18,
                      endIndent: 18,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item ──────────────────────────────────────────────────────────────────────

class _Item {
  final IconData icon;
  final String text;
  final bool positive;

  const _Item({
    required this.icon,
    required this.text,
    this.positive = true,
  });

  Widget _buildRow() {
    final iconColor = icon == Icons.cancel_outlined
        ? const Color(0xFFC62828)
        : icon == Icons.check_circle_outline_rounded
            ? const Color(0xFF2E7D32)
            : _accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: _textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rainbow rotating border painter ──────────────────────────────────────────

class _RainbowPillPainter extends CustomPainter {
  final double rotation;

  static const _colors = [
    Color(0xFFFF0000),
    Color(0xFFFF7F00),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFF8B00FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];
  static const _strokeW = 2.0;
  static const _radius = 20.0;
  // More steps = smoother gradient; 120 is imperceptible at 2px stroke.
  static const _steps = 120;

  const _RainbowPillPainter(this.rotation);

  Color _colorAt(double t) {
    final scaled = t * (_colors.length - 1);
    final idx = scaled.floor().clamp(0, _colors.length - 2);
    return Color.lerp(_colors[idx], _colors[idx + 1], scaled - idx)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(_strokeW / 2),
        const Radius.circular(_radius - _strokeW / 2),
      ));

    final metric = path.computeMetrics().first;
    final total = metric.length;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeW
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < _steps; i++) {
      // Color position: evenly spaced around the full spectrum (0→1).
      paint.color = _colorAt(i / _steps);

      // Path position: offset by rotation so the whole band rotates.
      final t0 = (i / _steps + rotation) % 1.0;
      final t1 = ((i + 1) / _steps + rotation) % 1.0;
      final d0 = t0 * total;
      final d1 = t1 * total;

      if (d1 > d0) {
        canvas.drawPath(metric.extractPath(d0, d1), paint);
      } else {
        // Segment wraps past the seam point — draw in two halves.
        if (d0 < total) canvas.drawPath(metric.extractPath(d0, total), paint);
        if (d1 > 0) canvas.drawPath(metric.extractPath(0, d1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RainbowPillPainter old) => old.rotation != rotation;
}
