import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';

// null = use OM text glyph
const appNavIcons = <IconData?>[
  Icons.home_rounded,
  null,
  Icons.hotel_rounded,
  Icons.person_rounded,
  Icons.call_rounded,
];

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool dark;
  const AppBottomNav(
      {super.key, required this.currentIndex, required this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final bgColor = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final activeColor = dark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
    final activeBg = dark ? const Color(0xFF2C3A4A) : const Color(0xFFDCEAFB);
    final inactiveColor = dark ? const Color(0xFF8E8E93) : const Color(0xFF212121);
    final inactiveLabelColor = dark ? const Color(0xFF8E8E93) : const Color(0xFF757575);
    final shadowColor = dark ? Colors.black : AppColors.primary;

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad > 0 ? bottomPad : 10),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.30),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(appNavIcons.length, (i) {
              final active = i == currentIndex;
              final labels = AppL10n.s.bottomNavLabels;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        width: 44,
                        height: 34,
                        decoration: BoxDecoration(
                          color: active ? activeBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: appNavIcons[i] != null
                            ? Icon(appNavIcons[i],
                                size: 20,
                                color: active ? activeColor : inactiveColor)
                            : Center(
                                child: Text(
                                  'ॐ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    height: 1,
                                    color: active ? activeColor : inactiveColor,
                                    fontFamily: null,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? activeColor : inactiveLabelColor,
                          letterSpacing: 0.1,
                        ),
                        child: Text(labels[i]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
