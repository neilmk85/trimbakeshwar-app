import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../constants/app_l10n.dart';
import '../services/language_service.dart';
import '../widgets/widgets.dart';
import 'trimbakeshwar_screen.dart';
import 'guruji_screen.dart';
import 'pooja_screen.dart';
import 'rooms_screen.dart';
import 'gallery_screen.dart';
import 'contact_screen.dart';
import 'mantra_screen.dart';
import 'account_screen.dart';

// Bottom nav index → screen index
// Screen 4 = Gallery (drawer only), Screen 7 = Account (bottom nav tab 3)
const _navToScreen = [0, 2, 3, 7, 5];

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final int? initialScreenIndex;
  const HomeScreen({super.key, this.initialIndex = 0, this.initialScreenIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _screenIndex;
  late int _navIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initialScreenIndex != null) {
      _screenIndex = widget.initialScreenIndex!;
      final ni = _navToScreen.indexOf(_screenIndex);
      _navIndex = ni >= 0 ? ni : -1;
    } else {
      _navIndex    = widget.initialIndex;
      _screenIndex = _navToScreen[widget.initialIndex];
    }
    LanguageService.isHindi.addListener(_onLangChange);
  }

  void _onLangChange() => setState(() {});

  @override
  void dispose() {
    LanguageService.isHindi.removeListener(_onLangChange);
    super.dispose();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:  return TrimbakeshwarScreen(onNavigateToPooja: () => _onNavTap(1));
      case 1:  return const GurujiScreen();
      case 2:  return const PoojaScreen();
      case 3:  return const RoomsScreen();
      case 4:  return const GalleryScreen();
      case 5:  return const ContactScreen();
      case 6:  return const MantraScreen();
      case 7:  return AccountScreen(onNavigateToTab: (i) => _onNavTap(i));
      default: return const TrimbakeshwarScreen();
    }
  }

  void _onNavTap(int navIdx) {
    setState(() {
      _navIndex    = navIdx;
      _screenIndex = _navToScreen[navIdx];
    });
  }

  bool get _isImmersive =>
      _screenIndex == 0 || _screenIndex == 1 || _screenIndex == 2 ||
      _screenIndex == 3 || // RoomsScreen — edge-to-edge photo header
      _screenIndex == 5 || _screenIndex == 6 ||
      _screenIndex == 7; // AccountScreen owns its own header

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: _isImmersive,
      appBar: _isImmersive
          ? AppBar(
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
            )
          : GradientAppBar(title: AppL10n.s.navTitle(_screenIndex)),
      drawer: AppDrawer(
        selectedIndex: _screenIndex,
        onItemSelected: (index) {
          // Sync bottom nav if the drawer item matches a nav tab
          final navIdx = _navToScreen.indexOf(index);
          setState(() {
            _screenIndex = index;
            _navIndex    = navIdx >= 0 ? navIdx : -1;
          });
        },
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey('${_screenIndex}_${LanguageService.isHindi.value}'),
          child: _getScreen(_screenIndex),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}


