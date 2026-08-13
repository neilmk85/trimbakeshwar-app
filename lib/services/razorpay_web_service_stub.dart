/// Stub for non-web platforms — RazorpayWebService is web-only.
class RazorpayWebService {
  static Future<dynamic> open({
    required String key,
    required int amount,
    required String orderId,
    required String currency,
    required String name,
    required String description,
    required String prefillContact,
    required String prefillEmail,
    required String prefillName,
    required String themeColor,
  }) async {
    throw UnsupportedError('RazorpayWebService is only available on Flutter Web');
  }
}
