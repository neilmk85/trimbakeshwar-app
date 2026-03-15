import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'trimbakeshwar_screen.dart';
import 'guruji_screen.dart';
import 'temple_screen.dart';
import 'pooja_screen.dart';
import 'gallery_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const TrimbakeshwarScreen();
      case 1:
        return const GurujiScreen();
      case 2:
        return const TempleScreen();
      case 3:
        return const PoojaScreen();
      case 4:
        return const GalleryScreen();
      case 5:
        return const ContactScreen();
      default:
        return const TrimbakeshwarScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: AppData.navTitles[_selectedIndex]),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getScreen(_selectedIndex),
      ),
    );
  }
}
