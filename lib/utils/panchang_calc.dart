import 'dart:math' as math;

/// Simplified Vedic Panchang calculator using Jean Meeus astronomical algorithms.
/// Accurate to within ~1 Tithi for dates 1900–2100.
class PanchangCalc {
  static const _tithiNames = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima',
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasya',
  ];

  static const _nakshatraNames = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
    'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
    'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
    'Uttara Ashadha', 'Shravana', 'Dhanishtha', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];

  static const _yogaNames = [
    'Vishkambha', 'Preeti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shula', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti',
  ];

  static const _varaNames = [
    'Ravivara', 'Somavara', 'Mangalavara', 'Budhavara',
    'Guruvara', 'Shukravara', 'Shanivara',
  ];

  static const _pakshNames = ['Shukla Paksha', 'Krishna Paksha'];

  /// Returns panchang for [date] (in IST / local time).
  static PanchangData calculate(DateTime date) {
    // Convert to Julian Day Number at noon IST (UTC+5:30)
    final utc = date.toUtc();
    final jd = _julianDay(utc.year, utc.month, utc.day,
        utc.hour + utc.minute / 60.0 + utc.second / 3600.0);

    final sunLon = _sunLongitude(jd);
    final moonLon = _moonLongitude(jd);

    // Tithi: each Tithi = 12° of elongation between Moon and Sun
    double elongation = (moonLon - sunLon) % 360;
    if (elongation < 0) elongation += 360;
    final tithiIndex = (elongation / 12).floor();
    final tithi = _tithiNames[tithiIndex % 30];
    final paksha = tithiIndex < 15 ? _pakshNames[0] : _pakshNames[1];

    // Nakshatra: Moon covers 27 nakshatras in 360°, each = 13.33°
    final nakshatraIndex = (moonLon / (360.0 / 27)).floor() % 27;
    final nakshatra = _nakshatraNames[nakshatraIndex];

    // Vara: weekday (0=Sun, 1=Mon … 6=Sat)
    final weekday = date.weekday % 7; // dart: 1=Mon … 7=Sun → shift
    final varaIndex = date.weekday == 7 ? 0 : date.weekday;
    final vara = _varaNames[varaIndex];

    // Yoga: (Sun + Moon) / (360/27) — 27 yogas
    final yogaIndex = (((sunLon + moonLon) % 360) / (360.0 / 27)).floor() % 27;
    final yoga = _yogaNames[yogaIndex];

    // Karana: half-Tithi (0–10 repeating pattern of 11 karanas)
    final karanaIndex = ((elongation / 6).floor()) % 11;
    final karanas = [
      'Bava', 'Balava', 'Kaulava', 'Taitila', 'Garija',
      'Vanija', 'Vishti', 'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna',
    ];
    final karana = karanas[karanaIndex];

    return PanchangData(
      tithi: tithi,
      paksha: paksha,
      nakshatra: nakshatra,
      vara: vara,
      yoga: yoga,
      karana: karana,
      tithiNumber: tithiIndex % 15 + 1,
    );
  }

  static double _julianDay(int y, int m, int d, double h) {
    if (m <= 2) { y -= 1; m += 12; }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d + h / 24.0 + b - 1524.5;
  }

  // Simplified Sun longitude (ecliptic, degrees)
  static double _sunLongitude(double jd) {
    final n = jd - 2451545.0;
    final L = (280.460 + 0.9856474 * n) % 360;
    final g = _rad((357.528 + 0.9856003 * n) % 360);
    final lon = L + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g);
    return lon % 360;
  }

  // Simplified Moon longitude (ecliptic, degrees) — accurate to ~0.5°
  static double _moonLongitude(double jd) {
    final n = jd - 2451545.0;
    final L0 = (218.316 + 13.176396 * n) % 360;
    final M = _rad((134.963 + 13.064993 * n) % 360);
    final F = _rad((93.272 + 13.229350 * n) % 360);
    final lon = L0 + 6.289 * math.sin(M) - 1.274 * math.sin(2 * F - M)
        + 0.658 * math.sin(2 * F) - 0.214 * math.sin(2 * M)
        - 0.186 * math.sin(_rad((357.528 + 0.9856003 * n) % 360));
    return lon % 360;
  }

  static double _rad(double deg) => deg * math.pi / 180;
}

class PanchangData {
  final String tithi;
  final String paksha;
  final String nakshatra;
  final String vara;
  final String yoga;
  final String karana;
  final int tithiNumber;

  const PanchangData({
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.vara,
    required this.yoga,
    required this.karana,
    required this.tithiNumber,
  });
}
