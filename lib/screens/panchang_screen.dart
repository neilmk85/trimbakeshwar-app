import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../utils/panchang_calc.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> {
  DateTime _selected = DateTime.now();

  static const _months = ['', 'January', 'February', 'March', 'April', 'May',
      'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const _weekdays = ['', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _shortMonths = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  bool get _isToday {
    final now = DateTime.now();
    return _selected.year == now.year &&
        _selected.month == now.month &&
        _selected.day == now.day;
  }

  String get _dateStr =>
      '${_weekdays[_selected.weekday]}, ${_selected.day} ${_months[_selected.month]} ${_selected.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select date for Panchang',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4A148C),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selected = picked);
  }

  @override
  Widget build(BuildContext context) {
    final data = PanchangCalc.calculate(_selected);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(AppL10n.s.panchangTitle),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.appBarGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              if (!_isToday)
                TextButton(
                  onPressed: () => setState(() => _selected = DateTime.now()),
                  child: Text(AppL10n.s.todayLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date selector bar ────────────────────────────────────
                  _DateSelector(
                    selected: _selected,
                    isToday: _isToday,
                    onPrev: () => setState(() =>
                        _selected = _selected.subtract(const Duration(days: 1))),
                    onNext: () =>
                        setState(() => _selected = _selected.add(const Duration(days: 1))),
                    onPick: _pickDate,
                    shortMonths: _shortMonths,
            ),
            const SizedBox(height: 16),

            // ── Header card ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A148C).withValues(alpha: 0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ॐ', style: TextStyle(
                        fontSize: 28,
                        color: Colors.amber.shade200,
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isToday ? 'आज का पंचांग' : 'पंचांग',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(_dateStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(AppL10n.s.todayLabel,
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.tithi,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(data.paksha,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Pancha Angas ───────────────────────────────────────────────
            _SectionTitle(AppL10n.s.panchaAngasHeading),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row 1: Tithi + Nakshatra
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: _CompactAngaCell(
                          icon: '🌙', label: AppL10n.s.tithiLabel,
                          value: data.tithi,
                          sub: '${data.tithiNumber}  •  ${data.paksha}',
                          color: const Color(0xFF4A148C),
                          isFirst: true,
                        )),
                        _cellDividerV(),
                        Expanded(child: _CompactAngaCell(
                          icon: '⭐', label: AppL10n.s.nakshatraLabel,
                          value: data.nakshatra,
                          sub: 'Moon\'s mansion',
                          color: const Color(0xFF1565C0),
                        )),
                      ],
                    ),
                  ),
                  _cellDividerH(),
                  // Row 2: Vara + Yoga
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: _CompactAngaCell(
                          icon: '☀️', label: AppL10n.s.varaLabel,
                          value: data.vara,
                          sub: 'Day of week',
                          color: const Color(0xFFE65100),
                          isFirst: true,
                        )),
                        _cellDividerV(),
                        Expanded(child: _CompactAngaCell(
                          icon: '✨', label: AppL10n.s.yogaLabel,
                          value: data.yoga,
                          sub: 'Sun + Moon',
                          color: const Color(0xFF2E7D32),
                        )),
                      ],
                    ),
                  ),
                  _cellDividerH(),
                  // Row 3: Karana — full width
                  _CompactAngaCell(
                    icon: '🔮', label: AppL10n.s.karanaLabel,
                    value: data.karana,
                    sub: 'Half-Tithi period',
                    color: const Color(0xFF00695C),
                    isFirst: true,
                    fullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _SectionTitle(AppL10n.s.panchangAbout),
            const SizedBox(height: 12),
            _InfoCard(items: [
              _InfoRow(label: AppL10n.s.tithiLabel, desc: AppL10n.s.tithiDesc),
              _InfoRow(label: AppL10n.s.nakshatraLabel, desc: AppL10n.s.nakshatraDesc),
              _InfoRow(label: AppL10n.s.varaLabel, desc: AppL10n.s.varaDesc),
              _InfoRow(label: AppL10n.s.yogaLabel, desc: AppL10n.s.yogaDesc),
              _InfoRow(label: AppL10n.s.karanaLabel, desc: AppL10n.s.karanaDesc),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ],
),
    );
  }
}

// ── Date selector bar ─────────────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  final DateTime selected;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;
  final List<String> shortMonths;

  const _DateSelector({
    required this.selected,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
    required this.shortMonths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous day
          _NavButton(icon: Icons.chevron_left, onTap: onPrev),

          // Date label — tappable to open picker
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 16, color: Color(0xFF4A148C)),
                    const SizedBox(width: 8),
                    Text(
                      '${selected.day} ${shortMonths[selected.month]} ${selected.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A148C).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(AppL10n.s.todayLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4A148C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Next day
          _NavButton(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Icon(icon, color: const Color(0xFF4A148C), size: 22),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
          letterSpacing: 0.2,
        )),
      ],
    );
  }
}

// ── Compact anga grid cell ────────────────────────────────────────────────────

Widget _cellDividerH() => Divider(
    height: 1, thickness: 1,
    color: Colors.grey.withValues(alpha: 0.10));

Widget _cellDividerV() => VerticalDivider(
    width: 1, thickness: 1,
    color: Colors.grey.withValues(alpha: 0.10));

class _CompactAngaCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool isFirst;
  final bool fullWidth;

  const _CompactAngaCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.isFirst = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                )),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(
                  fontSize: fullWidth ? 15 : 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                )),
                Text(sub, style: TextStyle(
                  fontSize: 10.5,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(items[i].label, style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A148C),
                    )),
                  ),
                  Expanded(
                    child: Text(items[i].desc, style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    )),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16,
                  color: Colors.grey.withValues(alpha: 0.12)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String desc;
  const _InfoRow({required this.label, required this.desc});
}
