import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialMediaLinks {
  final String website;
  final String facebook;
  final String instagram;
  final String youtube;

  SocialMediaLinks({
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.youtube,
  });

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) {
    return SocialMediaLinks(
      website: json['website'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }
}

class SettingsService {
  static const _baseUrl = 'https://app.trimbakeshwarpoojavidhi.in/api/settings';

  static Future<SocialMediaLinks?> getSocialMediaLinks() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/social-media'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return SocialMediaLinks.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
