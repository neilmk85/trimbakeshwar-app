/// Central registry of all server-hosted images.
/// Usage:  AppImages.url('filename.jpg')
/// Or use the named constants directly, e.g. AppImages.trimbakeshwarTemple
const String _imgBase = 'https://app.trimbakeshwarpoojavidhi.in/uploads/images';

class AppImages {
  AppImages._();

  static String url(String filename) => '$_imgBase/$filename';

  // ── Shiva ─────────────────────────────────────────────────────────────────
  static final String shiva           = url('shiva.png');
  static final String shivaMeditating = url('shiva_meditating.png');

  // ── Temple & Landmarks ────────────────────────────────────────────────────
  static final String trimbakeshwarTemple = url('trimbakeshwar-temple.png');
  static final String brahmagiriParvat    = url('Brahmagiri-Parvat.jpg');
  static final String kushawartaKunda     = url('kushawarta-kunda.jpg');
  static final String gangaDwar           = url('ganga-dwar.jpg');
  static final String kumbhaMela          = url('kumbha-mela-2027.png');
  static final String muktidhamTemple     = url('muktidham-temple.jpg');
  static final String nivruttinathTemple  = url('nivruttinath-temple.jpg');
  static final String pandavleniCaves     = url('pandavleni-caves.jpg');
  static final String anjaneriHills       = url('anjaneri-hills.jpg');
  static final String coinMuseum          = url('coin-museum-nashik.jpeg');

  // ── Pooja ─────────────────────────────────────────────────────────────────
  static final String narayanNagbali    = url('narayan-nagbali.png');
  static final String kalsarpaShanti    = url('kalsarpa-shanti.png');
  static final String tripindi          = url('tripindi.png');
  static final String rudraAbhishek     = url('rudra-abhishek.png');
  static final String mahamrityunjayJaap = url('mahamrutunjay-jaap-banner.png');
  static final String laghuRudra        = url('laghu-rudra.png');
  static final String navgrahShanti     = url('navagraha-shanti.png');
  static final String vastuShanti      = url('vastu-shanti.jpeg');

  // ── Guruji ────────────────────────────────────────────────────────────────
  static final String skGuruji        = url('sk_guruji.png');
  static final String skGurujiWhite   = url('sk_guruji_white.png');
  static final String guruji          = url('guruji.jpg');
  static final String skGurujiCosmic1 = 'https://app.trimbakeshwarpoojavidhi.in/static/images/sk_guruji_cosmic1.jpg';

  /// Convert an 'assets/images/foo.jpg' path → server URL.
  static String fromAsset(String assetPath) {
    final filename = assetPath.split('/').last;
    return url(filename);
  }
}
