import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TrimbakeshwarScreen extends StatelessWidget {
  const TrimbakeshwarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withOpacity(0.08),
                  AppColors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Hero Banner
                Container(
                  width: double.infinity, 
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ॐ नमः शिवाय',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppColors.white,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'TRIMBAKESHWAR JYOTIRLINGA',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'About Trimbakeshwar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.aboutTrimbakeshwar,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey700,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Info Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoCard(
                  Icons.temple_hindu_rounded,
                  'Sacred Jyotirlinga',
                  'The Trimbakeshwar Jyotirlinga has three faces embodying Lord Brahma, Lord Vishnu and Lord Shiva.',
                ),
                _infoCard(
                  Icons.water_drop_rounded,
                  'Origin of Godavari',
                  'The Godavari river originates near Trimbakeshwar from the Brahmagiri mountain.',
                ),
                _infoCard(
                  Icons.auto_awesome_rounded,
                  'Narayan Nagbali Pooja',
                  'Trimbakeshwar is the only place where the sacred Narayan Nagbali and Kalsarpa Shanti poojas can be performed.',
                ),
                _infoCard(
                  Icons.calendar_month_rounded,
                  'Sinhastha Kumbh Mela',
                  'The town hosts the Sinhastha Kumbh Mela every 12 years, attracting millions of devotees.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryMedium.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
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
                    fontSize: 16,
                    color: AppColors.navyDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
