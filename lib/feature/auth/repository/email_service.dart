import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String serviceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String templateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';

  static Future<bool> sendTwoFactorCode({
    required String toEmail,
    required String code,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'to_email': toEmail,
          'otp_code': code,
          'subject': 'Your verification code',
        },
      }),
    );

    return response.statusCode == 200;
  }
}
