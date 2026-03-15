import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.appBarGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      color: Colors.white24,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.person, size: 60, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.gurujiName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vedic Priest | Trimbakeshwar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trimbakeshwar, Nashik, Maharashtra',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact Tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(textAlign: TextAlign.center, 'Address - Trimbak')
                    ],
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.chat, color: Colors.green),
                      title: const Text('WhatsApp'),
                      subtitle: const Text('Chat with us on WhatsApp'),
                      onTap: () {},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.fork_left,
                      color: Colors.lightBlue,
                    ),
                    title: const Text('Testing Icon'),
                    subtitle: const Text('Testing Icon style'),
                    onTap: () => UrlHelper.launch(AppStrings.whatsappUrl),
                  ),
                  _ContactTile(
                    icon: Icons.phone_rounded,
                    iconColor: AppColors.primary,
                    title: 'Call Us',
                    subtitle: AppStrings.phoneDisplay,
                    onTap: () => UrlHelper.call(AppStrings.phoneNumber),
                  ),
                  _ContactTile(
                    icon: Icons.chat_rounded,
                    iconColor: AppColors.whatsapp,
                    title: 'WhatsApp',
                    subtitle: 'Chat with us on WhatsApp',
                    onTap: () => UrlHelper.launch(AppStrings.whatsappUrl),
                  ),
                  _ContactTile(
                    icon: Icons.map_rounded,
                    iconColor: AppColors.googleRed,
                    title: 'Google Maps',
                    subtitle: 'Get directions to Trimbakeshwar Temple',
                    onTap: () =>
                        UrlHelper.openMaps('Trimbakeshwar Temple Nashik'),
                  ),
                  _ContactTile(
                    icon: Icons.star_border_sharp,
                    iconColor: AppColors.twitter,
                    title: 'Google Reviews',
                    subtitle: 'Leave us a review on Google',
                    onTap: () => UrlHelper.launch(AppStrings.googleReviewUrl),
                  ),
                  _ContactTile(
                    icon: Icons.email,
                    iconColor: AppColors.grey700,
                    title: 'Email',
                    subtitle: AppStrings.email,
                    onTap: () => UrlHelper.sendEmail(AppStrings.email),
                  ),
                  _ContactTile(
                    icon: Icons.language_outlined,
                    iconColor: AppColors.webBlue,
                    title: 'Website',
                    subtitle: 'www.kaalsarpashanti.com',
                    onTap: () => UrlHelper.launch(AppStrings.websiteUrl),
                  ),
                ],
              ),
            ),

            // Social Media
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'Follow Us',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialButton(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            color: AppColors.facebook),
                        _SocialButton(
                            icon: Icons.camera_alt,
                            label: 'Instagram',
                            color: AppColors.instagram),
                        _SocialButton(
                            icon: Icons.play_circle_filled,
                            label: 'YouTube',
                            color: AppColors.youtube),
                        _SocialButton(
                            icon: Icons.alternate_email,
                            label: 'Twitter',
                            color: AppColors.twitter),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Private Widgets ───────────────────────────

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.grey500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}
