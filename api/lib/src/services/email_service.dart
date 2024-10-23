import 'package:dotenv/dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  late final String senderEmail;
  late final String appPassword;
  late final SmtpServer smtpServer;

  EmailService() {
    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();

      senderEmail = env['SENDER_EMAIL'] as String;
      appPassword = env['APP_PASSWORD'] as String;

      if (senderEmail.isEmpty || appPassword.isEmpty) {
        throw Exception('SENDER_EMAIL or APP_PASSWORD is not set in the environment variables.');
      }

      smtpServer = gmail(senderEmail, appPassword);
    } catch (e) {
      print('Failed to initialize EmailService: $e');
      rethrow;
    }
  }

  Future<void> _sendEmail(String recipientEmail, String subject, String body) async {
    final message = Message()
      ..from = Address(senderEmail, 'QRIMS Support')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      print('Message not sent. $e');
      throw Exception('Failed to send email.');
    }
  }

  Future<void> sendOtpEmail(String email, String otp) async {
    final subject = 'Your QRIMS Email Verification Code';
    final body = '''
    Hello,

    Your OTP code is: $otp

    If you did not request this, please ignore this email.

    Best regards,
    The QRIMS Team
    ''';
    await _sendEmail(email, subject, body);
  }

  Future<void> sendAdminApprovalEmail(String email) async {
    final subject = 'Your Account Has Been Approved';
    final body = '''
    Greetings!
    
    We're happy to inform you that your account has been approved!
    
    Best regards,
    The QRIMS Team
    ''';
    await _sendEmail(email, subject, body);
  }
}
