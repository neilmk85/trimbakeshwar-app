import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  UrlHelper._();

  static Future<void> launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> call(String number) async {
    await launch('tel:$number');
  }

  static Future<void> sendEmail(String email) async {
    await launch('mailto:$email');
  }

  static Future<void> openWhatsApp(String number) async {
    await launch('https://wa.me/$number');
  }

  static Future<void> openMaps(String query) async {
    await launch('https://maps.app.goo.gl/4HPUmo4shT6VVerK8');
  }
}
