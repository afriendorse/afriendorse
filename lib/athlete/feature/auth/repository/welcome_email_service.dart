// lib/feature/auth/repository/welcome_email_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service responsible for sending welcome emails via Mailtrap
class WelcomeEmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // MAILTRAP CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Your Mailtrap API token (from Mailtrap dashboard → API Keys)
  /// Store this securely using flutter_secure_storage or environment variables
  static const String _mailtrapApiToken = 'd99ee7298d0ef6d3978859cbf890a5b9';

  /// Mailtrap Inbox ID for Email Testing (sandbox)
  /// Get this from your Mailtrap inbox URL or dashboard
  static const String _mailtrapInboxId = 'YOUR_INBOX_ID'; // e.g., '1234567'

  /// Mailtrap Domain for Email Sending (production)
  /// Get this from Mailtrap → Sending → Domains
  static const String _mailtrapSendingDomain = 'sandbox.smtp.mailtrap.io';

  /// Mailtrap Sending API endpoint (for production emails)
  static const String _mailtrapSendingApiBase =
      'https://send.api.mailtrap.io/api/send';

  /// Mailtrap Testing API endpoint (for sandbox/testing)
  static const String _mailtrapTestingApiBase =
      'https://sandbox.api.mailtrap.io/api/send';

  /// Set to false when you're ready to send real emails
  static const bool _useSandbox = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends a welcome email to a newly registered athlete via Mailtrap
  static Future<bool> sendWelcomeEmail({
    required String email,
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) async {
    try {
      // Prevent duplicate welcome emails
      final alreadySent = await wasWelcomeEmailSent(email);
      if (alreadySent) {
        if (kDebugMode) print('ℹ️ Welcome email already sent to: $email');
        return true;
      }

      // Build the email payload
      final payload = _buildMailtrapPayload(
        toEmail: email,
        toName: firstName,
        firstName: firstName,
        companyName: companyName,
        fieldOfSport: fieldOfSport,
      );

      bool success;

      if (_useSandbox) {
        // Use Mailtrap Testing API (emails go to your Mailtrap inbox, not real inbox)
        success = await _sendViaMailtrapTesting(payload);
      } else {
        // Use Mailtrap Sending API (emails go to real inboxes)
        success = await _sendViaMailtrapSending(payload);
      }

      if (success) {
        await _logWelcomeEmailSent(email);
        if (kDebugMode) print('✅ Welcome email sent via Mailtrap to: $email');
      }

      return success;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Mailtrap welcome email failed: $e');
        print('📍 StackTrace: $stackTrace');
      }
      return false;
    }
  }

  /// Checks if welcome email was already sent
  static Future<bool> wasWelcomeEmailSent(String email) async {
    try {
      final docId = email.trim().toLowerCase();
      final doc = await _firestore.collection('athletes').doc(docId).get();
      return doc.data()?['welcomeEmailSent'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Resends welcome email (for admin panel or support requests)
  static Future<bool> resendWelcomeEmail(String email) async {
    try {
      final docId = email.trim().toLowerCase();
      final doc = await _firestore.collection('athletes').doc(docId).get();

      if (!doc.exists) return false;

      final data = doc.data()!;

      // Reset the flag temporarily to allow resend
      await _firestore.collection('athletes').doc(docId).update({
        'welcomeEmailSent': false,
      });

      return await sendWelcomeEmail(
        email: email,
        firstName: data['firstName'] ?? 'Athlete',
        companyName: data['companyName'] ?? '',
        fieldOfSport: data['fieldOfSport'] ?? 'General',
      );
    } catch (e) {
      if (kDebugMode) print('❌ Resend welcome email failed: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Builds the Mailtrap API payload with HTML template
  static Map<String, dynamic> _buildMailtrapPayload({
    required String toEmail,
    required String toName,
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) {
    final htmlContent = _buildWelcomeEmailHtml(
      firstName: firstName,
      companyName: companyName,
      fieldOfSport: fieldOfSport,
    );

    return {
      'to': [
        {'email': toEmail, 'name': toName},
      ],
      'from': {'email': 'welcome@afriendorse.com', 'name': 'AfriEndorse Team'},
      'subject': 'Welcome to AfriEndorse, $firstName! 🎉',
      'html': htmlContent,
      'text': _buildWelcomeEmailText(
        firstName: firstName,
        companyName: companyName,
        fieldOfSport: fieldOfSport,
      ),
      'category': 'welcome_email',
      // Custom variables for Mailtrap analytics
      'custom_variables': {
        'user_type': 'athlete',
        'registration_source': 'mobile_app',
        'sport': fieldOfSport,
      },
    };
  }

  /// Sends email via Mailtrap Testing API (sandbox - emails captured in Mailtrap inbox)
  static Future<bool> _sendViaMailtrapTesting(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_mailtrapTestingApiBase/$_mailtrapInboxId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Api-Token': _mailtrapApiToken,
              'Authorization': 'Bearer $_mailtrapApiToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📧 Mailtrap Testing API Response: ${response.statusCode}');
        print('📧 Response Body: ${response.body}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('❌ Mailtrap Testing API error: $e');
      return false;
    }
  }

  /// Sends email via Mailtrap Sending API (production - emails go to real inboxes)
  static Future<bool> _sendViaMailtrapSending(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_mailtrapSendingApiBase),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Api-Token': _mailtrapApiToken,
              'Authorization': 'Bearer $_mailtrapApiToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📧 Mailtrap Sending API Response: ${response.statusCode}');
        print('📧 Response Body: ${response.body}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('❌ Mailtrap Sending API error: $e');
      return false;
    }
  }

  /// Logs welcome email status in Firestore
  static Future<void> _logWelcomeEmailSent(String email) async {
    try {
      final docId = email.trim().toLowerCase();
      await _firestore.collection('athletes').doc(docId).set({
        'welcomeEmailSent': true,
        'welcomeEmailSentAt': FieldValue.serverTimestamp(),
        'welcomeEmailStatus': 'delivered',
        'welcomeEmailProvider': 'mailtrap',
        'welcomeEmailEnvironment': _useSandbox ? 'sandbox' : 'production',
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('❌ Failed to log welcome email: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standardized AfriEndorse HTML welcome email template
  /// Uses: #045F25 (Deep Green), #000000 (Black), #FFFFFF (White)
  static String _buildWelcomeEmailHtml({
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css">
        @media screen {
            @font-face {
                font-family: 'Source Sans Pro';
                font-style: normal;
                font-weight: 400;
                src: local('Source Sans Pro Regular'), local('SourceSansPro-Regular'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlBM0YzuT7MdOe03otPbuUS0.woff) format('woff');
            }
            @font-face {
                font-family: 'Source Sans Pro';
                font-style: normal;
                font-weight: 700;
                src: local('Source Sans Pro Bold'), local('SourceSansPro-Bold'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/toadOcfmlt9b38dHJxOBGFkQc6VGVFSmCnC_l7QZG60.woff) format('woff');
            }
        }
        body, table, td, a {
            -ms-text-size-adjust: 100%;
            -webkit-text-size-adjust: 100%;
        }
        table, td {
            mso-table-rspace: 0pt;
            mso-table-lspace: 0pt;
        }
        img {
            -ms-interpolation-mode: bicubic;
            height: auto;
            line-height: 100%;
            text-decoration: none;
            border: 0;
            outline: none;
        }
        a[x-apple-data-detectors] {
            font-family: inherit !important;
            font-size: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
            color: inherit !important;
            text-decoration: none !important;
        }
        div[style*="margin: 16px 0;"] {
            margin: 0 !important;
        }
        body {
            width: 100% !important;
            height: 100% !important;
            padding: 0 !important;
            margin: 0 !important;
            background-color: #f4f4f4;
            font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif;
        }
        table {
            border-collapse: collapse !important;
        }
        a {
            color: #045F25;
            text-decoration: none;
        }
        .email-wrapper {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
        }
        .email-header {
            background-color: #045F25;
            padding: 30px 40px;
            text-align: center;
        }
        .email-header .brand-name {
            color: #ffffff;
            font-size: 24px;
            font-weight: 700;
            margin: 0;
            letter-spacing: 1px;
        }
        .email-header .tagline {
            color: rgba(255, 255, 255, 0.8);
            font-size: 13px;
            margin: 6px 0 0;
            font-weight: 400;
        }
        .email-body {
            padding: 40px;
            color: #000000;
            font-size: 15px;
            line-height: 1.6;
            background-color: #ffffff;
        }
        .email-body h2 {
            color: #045F25;
            font-size: 22px;
            font-weight: 700;
            margin: 0 0 20px;
        }
        .email-body h3 {
            color: #000000;
            font-size: 18px;
            font-weight: 700;
            margin: 0 0 12px;
        }
        .email-body p {
            margin: 0 0 16px;
        }
        .info-card {
            background-color: #f9f9f9;
            border-left: 4px solid #045F25;
            border-radius: 0 10px 10px 0;
            padding: 20px 24px;
            margin: 20px 0;
        }
        .info-card p {
            margin: 0 0 8px;
            font-size: 14px;
        }
        .info-card strong {
            color: #045F25;
        }
        .sport-badge {
            display: inline-block;
            background-color: #045F25;
            color: #ffffff;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        .btn-primary {
            display: inline-block;
            padding: 14px 32px;
            background-color: #045F25;
            color: #ffffff !important;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 700;
            font-size: 14px;
            margin: 10px 0;
        }
        .feature-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .feature-item {
            margin-bottom: 12px;
            font-size: 14px;
            color: #4A4A4A;
            line-height: 1.5;
        }
        .feature-check {
            color: #045F25;
            font-weight: 700;
            margin-right: 8px;
        }
        .divider {
            border: none;
            border-top: 1px solid #e0e0e0;
            margin: 30px 0;
        }
        .small-text {
            font-size: 13px;
            color: #666666;
        }
        .email-footer {
            background-color: #000000;
            padding: 30px 40px;
            text-align: center;
        }
        .email-footer .company-name {
            color: #ffffff;
            font-size: 14px;
            font-weight: 700;
            margin: 0 0 4px;
        }
        .email-footer .footer-links {
            margin-bottom: 16px;
        }
        .email-footer .footer-links a {
            color: #ffffff;
            font-size: 13px;
            margin: 0 12px;
            text-decoration: none;
        }
        .email-footer .social-links {
            margin: 16px 0;
        }
        .email-footer .social-links a {
            display: inline-block;
            margin: 0 8px;
        }
        .email-footer .social-links img {
            width: 22px;
            height: 22px;
            filter: brightness(0) invert(1);
        }
        .email-footer .copyright {
            color: rgba(255, 255, 255, 0.6);
            font-size: 12px;
            margin: 12px 0 0;
        }
        @media screen and (max-width: 600px) {
            .email-body, .email-header, .email-footer {
                padding: 24px !important;
            }
        }
    </style>
</head>
<body>
    <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="center" style="padding: 20px 0; background-color: #f4f4f4;">
                <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" class="email-wrapper" style="max-width: 600px;">
                    
                    <!-- HEADER -->
                    <tr>
                        <td class="email-header" style="background-color: #045F25; padding: 30px 40px; text-align: center;">
                            <p class="brand-name" style="color: #ffffff; font-size: 24px; font-weight: 700; margin: 0; letter-spacing: 1px;">
                                AfriEndorse
                            </p>
                            <p class="tagline" style="color: rgba(255,255,255,0.8); font-size: 13px; margin: 6px 0 0;">
                                Secure. Trusted. African.
                            </p>
                        </td>
                    </tr>

                    <!-- BODY -->
                    <tr>
                        <td class="email-body" style="padding: 40px; color: #000000; font-size: 15px; line-height: 1.6; background-color: #ffffff;">
                            
                            <h2 style="color: #045F25; font-size: 22px; font-weight: 700; margin: 0 0 20px;">
                                Welcome to AfriEndorse, $firstName!
                            </h2>

                            <h3 style="color: #000000; font-size: 18px; font-weight: 700; margin: 0 0 12px;">
                                Dear $firstName,
                            </h3>

                            <p>
                                We're thrilled to welcome you to the AfriEndorse community! Your account has been successfully created and you're now part of a network that connects athletes with incredible opportunities.
                            </p>

                            <!-- Account Info Card -->
                            <div class="info-card" style="background-color: #f9f9f9; border-left: 4px solid #045F25; border-radius: 0 10px 10px 0; padding: 20px 24px; margin: 20px 0;">
                                <p style="margin: 0 0 8px; font-size: 14px;">
                                    <strong style="color: #045F25;">Account:</strong> $companyName
                                </p>
                                <p style="margin: 0; font-size: 14px;">
                                    <strong style="color: #045F25;">Sport:</strong> 
                                    <span class="sport-badge" style="display: inline-block; background-color: #045F25; color: #ffffff; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 600;">🏅 $fieldOfSport</span>
                                </p>
                            </div>

                            <!-- CTA -->
                            <div style="text-align: center; margin: 24px 0;">
                                <a href="https://your-app.com/login" class="btn-primary" style="display: inline-block; padding: 14px 32px; background-color: #045F25; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: 700; font-size: 14px;">
                                    Go to Dashboard →
                                </a>
                            </div>

                            <!-- Features -->
                            <h3 style="color: #000000; font-size: 18px; font-weight: 700; margin: 0 0 12px;">What's Next?</h3>
                            <ul class="feature-list" style="list-style: none; padding: 0; margin: 0;">
                                <li class="feature-item" style="margin-bottom: 12px; font-size: 14px; color: #4A4A4A; line-height: 1.5;">
                                    <span class="feature-check" style="color: #045F25; font-weight: 700; margin-right: 8px;">✓</span>
                                    Complete your profile to stand out to brands and sponsors
                                </li>
                                <li class="feature-item" style="margin-bottom: 12px; font-size: 14px; color: #4A4A4A; line-height: 1.5;">
                                    <span class="feature-check" style="color: #045F25; font-weight: 700; margin-right: 8px;">✓</span>
                                    Browse and apply for exclusive deals and sponsorships
                                </li>
                                <li class="feature-item" style="margin-bottom: 12px; font-size: 14px; color: #4A4A4A; line-height: 1.5;">
                                    <span class="feature-check" style="color: #045F25; font-weight: 700; margin-right: 8px;">✓</span>
                                    Connect with teams, brands, and fellow athletes
                                </li>
                                <li class="feature-item" style="margin-bottom: 12px; font-size: 14px; color: #4A4A4A; line-height: 1.5;">
                                    <span class="feature-check" style="color: #045F25; font-weight: 700; margin-right: 8px;">✓</span>
                                    Start monetizing your athletic career
                                </li>
                            </ul>

                            <hr class="divider" style="border: none; border-top: 1px solid #e0e0e0; margin: 30px 0;">

                            <p class="small-text" style="font-size: 13px; color: #666666;">
                                Need help getting started? Our support team is always here for you at <a href="mailto:support@afriendorse.com" style="color: #045F25; font-weight: 600;">support@afriendorse.com</a>.
                            </p>

                            <p style="margin: 16px 0 0;">
                                <strong>Thanks & Regards,</strong><br>
                                AfriEndorse Team
                            </p>

                        </td>
                    </tr>

                    <!-- FOOTER -->
                    <tr>
                        <td class="email-footer" style="background-color: #000000; padding: 30px 40px; text-align: center;">
                            <p class="company-name" style="color: #ffffff; font-size: 14px; font-weight: 700; margin: 0 0 4px;">
                                AfriEndorse
                            </p>
                            <div class="footer-links" style="margin-bottom: 16px;">
                                <a href="#" style="color: #ffffff; font-size: 13px; margin: 0 12px; text-decoration: none;">Privacy Policy</a>
                                <a href="#" style="color: #ffffff; font-size: 13px; margin: 0 12px; text-decoration: none;">Contact Us</a>
                            </div>
                            <div class="social-links" style="margin: 16px 0;">
                                <a href="#" style="display: inline-block; margin: 0 8px;">
                                    <img src="https://cdn-icons-png.flaticon.com/512/733/733579.png" width="22" height="22" alt="Twitter" style="width: 22px; height: 22px; filter: brightness(0) invert(1);">
                                </a>
                                <a href="#" style="display: inline-block; margin: 0 8px;">
                                    <img src="https://cdn-icons-png.flaticon.com/512/733/733558.png" width="22" height="22" alt="Instagram" style="width: 22px; height: 22px; filter: brightness(0) invert(1);">
                                </a>
                                <a href="#" style="display: inline-block; margin: 0 8px;">
                                    <img src="https://cdn-icons-png.flaticon.com/512/733/733561.png" width="22" height="22" alt="LinkedIn" style="width: 22px; height: 22px; filter: brightness(0) invert(1);">
                                </a>
                            </div>
                            <p class="copyright" style="color: rgba(255,255,255,0.6); font-size: 12px; margin: 12px 0 0;">
                                © 2026 AfriEndorse. All rights reserved.<br>
                                You're receiving this because you created an account on AfriEndorse.
                            </p>
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>
</body>
</html>''';
  }

  /// Plain text version for email clients that don't support HTML
  static String _buildWelcomeEmailText({
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) {
    return '''
Welcome to AfriEndorse, $firstName! 🎉

Your account has been successfully created!

Account Details:
- Name: $companyName
- Sport: $fieldOfSport

What's Next?
✓ Complete your profile to stand out to brands and sponsors
✓ Browse and apply for exclusive deals and sponsorships
✓ Connect with teams, brands, and fellow athletes
✓ Start monetizing your athletic career

Login to your dashboard: https://your-app.com/login

Need help? Contact us at support@afriendorse.com

© 2026 AfriEndorse. All rights reserved.
''';
  }
}
