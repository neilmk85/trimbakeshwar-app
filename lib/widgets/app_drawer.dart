import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../constants/app_l10n.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../screens/login_screen.dart';
import '../screens/instructions_screen.dart';
import '../screens/jyotirlinga_screen.dart';
import '../screens/nearby_attractions_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, user, _) {
        return Drawer(
          child: Column(
            children: [
              _buildHeader(context, user),
              Expanded(child: _buildAllItems(context, user)),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllItems(BuildContext context, UserModel? user) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Main nav items
        ...List.generate(AppData.navTitles.length, (i) => _navItem(context, i)),
        // Extra screens
        _buildNearbyAttractionsItem(context),
        _buildJyotirlingaItem(context),
        _buildInstructionsItem(context),
        // Language toggle
        _buildLanguageToggleItem(context),
        // Auth
        _buildAuthItem(context, user),
        if (user != null) _buildMyOrdersItem(context),
        if (user != null) _buildLogoutItem(context),
      ],
    );
  }

  Widget _navItem(BuildContext context, int index) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? AppColors.primaryMedium.withValues(alpha: 0.12)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: FaIcon(
          AppData.navIcons[index],
          color: isSelected ? AppColors.primary : AppColors.grey700,
          size: 20,
        ),
        title: Text(
          AppL10n.s.navTitle(index),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.grey800,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          onItemSelected(index);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.appBarGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: user != null ? _loggedInHeader(user) : _defaultHeader(),
    );
  }

  Widget _loggedInHeader(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with initials
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2.5),
            color: Colors.white24,
          ),
          child: Center(
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 28,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.fullName,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        _headerInfoRow(Icons.phone, user.phone),
        if (user.email.isNotEmpty) ...[
          const SizedBox(height: 2),
          _headerInfoRow(Icons.email_outlined, user.email),
        ],
        if (user.city.isNotEmpty) ...[
          const SizedBox(height: 2),
          _headerInfoRow(
            Icons.location_on_outlined,
            '${user.city}, ${user.country}',
          ),
        ],
      ],
    );
  }

  Widget _defaultHeader() {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageService.isHindi,
      builder: (context, isHindi, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temple image avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://app.trimbakeshwarpoojavidhi.in/uploads/images/trimbakeshwar-temple.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white24,
                        child: const Center(
                          child: Text(
                            AppStrings.omSymbol,
                            style: TextStyle(
                              fontSize: 38,
                              color: AppColors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Language toggle chip
                GestureDetector(
                  onTap: () async {
                    await LanguageService.toggle();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isHindi ? 'A' : 'अ',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isHindi ? 'English' : 'हिंदी',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              AppStrings.drawerName,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            _headerInfoRow(Icons.phone, AppStrings.drawerPhone),
            const SizedBox(height: 2),
            _headerInfoRow(Icons.email_outlined, AppStrings.drawerEmail),
            const SizedBox(height: 2),
            _headerInfoRow(Icons.location_on_outlined, AppStrings.drawerLocation),
          ],
        );
      },
    );
  }

  Widget _headerInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyAttractionsItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: const Icon(Icons.place_rounded, color: AppColors.primary, size: 24),
        title: Text(
          AppL10n.s.nearbyAttractions,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
                builder: (_) => const NearbyAttractionsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildAuthItem(BuildContext context, UserModel? user) {
    final isLoggedIn = user != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: Icon(
          isLoggedIn ? Icons.person_rounded : Icons.login_rounded,
          color: AppColors.primary,
          size: 24,
        ),
        title: Text(
          isLoggedIn ? AppL10n.s.myProfile : AppL10n.s.loginLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop(); // close drawer
          if (isLoggedIn) {
            navigator.push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            navigator.push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildMyOrdersItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: const Icon(Icons.receipt_long_rounded,
            color: AppColors.primary, size: 24),
        title: Text(
          AppL10n.s.myOrders,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 24),
        title: Text(
          AppL10n.s.logoutLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          AuthService.logout().ignore();
        },
      ),
    );
  }

  Widget _buildJyotirlingaItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Text(
              '🔱',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: const Text(
          '12 Jyotirlingas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        subtitle: const Text(
          'Sacred abodes of Lord Shiva',
          style: TextStyle(fontSize: 11, color: AppColors.grey500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(builder: (_) => const JyotirlingaScreen()),
          );
        },
      ),
    );
  }

  Widget _buildInstructionsItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
        title: Text(
          AppL10n.s.instructions,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(builder: (_) => const InstructionsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLanguageToggleItem(BuildContext context) {
    final isHindi = LanguageService.isHindi.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Text(
              isHindi ? 'A' : 'अ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        title: Text(
          AppL10n.s.languageLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          AppL10n.s.languageSubtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.grey700),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () async {
          await LanguageService.toggle();
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        AppStrings.copyright,
        style: TextStyle(color: AppColors.grey500, fontSize: 12),
      ),
    );
  }
}
