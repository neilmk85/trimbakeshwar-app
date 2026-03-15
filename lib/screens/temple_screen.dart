import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TempleScreen extends StatelessWidget {
  const TempleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.temple_hindu, size: 70, color: Colors.white70),
                  SizedBox(height: 10),
                  Text(
                    'श्री त्र्यंबकेश्वर मंदिर',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Shri Trimbakeshwar Mandir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // History
                const Text(
                  'Temple History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.templeHistory,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Timings
                const Text(
                  'Temple Timings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...AppData.templeTimings.map(
                  (t) => _timingRow(t['event']!, t['time']!),
                ),
                const SizedBox(height: 24),

                // How to Reach
                const Text(
                  'How to Reach',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                _reachCard(Icons.flight, 'By Air',
                    'Nearest airport: Nashik (Ozar) Airport — 38 km'),
                _reachCard(Icons.train, 'By Train',
                    'Nearest railway: Nashik Road Station — 35 km'),
                _reachCard(Icons.directions_bus, 'By Road',
                    'Well connected by State Transport buses from Nashik, Mumbai & Pune'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timingRow(String event, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryMedium.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            event,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.navyDeep,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reachCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryMedium.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.navyDeep,
                    )),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.grey700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
