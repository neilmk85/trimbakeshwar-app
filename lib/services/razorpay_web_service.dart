// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';

/// Opens Razorpay checkout on Flutter Web using the JS bridge in index.html.
class RazorpayWebService {
  // ignore: library_private_types_in_public_api
  static Completer<_RazorpayResult>? _completer;

  static Future<_RazorpayResult> open({
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
  }) {
    _completer = Completer<_RazorpayResult>();

    // Register success callback
    js.context['_rzpSuccessCallback'] = js.allowInterop(
      (String paymentId, String razorpayOrderId, String signature) {
        _completer?.complete(_RazorpayResult.success(
          paymentId: paymentId,
          orderId: razorpayOrderId,
          signature: signature,
        ));
        _completer = null;
      },
    );

    // Register error/dismiss callback
    js.context['_rzpErrorCallback'] = js.allowInterop(
      (String code, String message) {
        _completer?.complete(_RazorpayResult.error(code: code, message: message));
        _completer = null;
      },
    );

    // Call the JS function defined in index.html
    js.context.callMethod('openRazorpayCheckout', [
      js.JsObject.jsify({
        'key': key,
        'amount': amount,
        'order_id': orderId,
        'currency': currency,
        'name': name,
        'description': description,
        'prefill_contact': prefillContact,
        'prefill_email': prefillEmail,
        'prefill_name': prefillName,
        'theme_color': themeColor,
      })
    ]);

    return _completer!.future;
  }
}

class _RazorpayResult {
  final bool success;
  final String paymentId;
  final String orderId;
  final String signature;
  final String? errorCode;
  final String? errorMessage;

  const _RazorpayResult._({
    required this.success,
    this.paymentId = '',
    this.orderId = '',
    this.signature = '',
    this.errorCode,
    this.errorMessage,
  });

  factory _RazorpayResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) =>
      _RazorpayResult._(
        success: true,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

  factory _RazorpayResult.error({
    required String code,
    required String message,
  }) =>
      _RazorpayResult._(
        success: false,
        errorCode: code,
        errorMessage: message,
      );
}
