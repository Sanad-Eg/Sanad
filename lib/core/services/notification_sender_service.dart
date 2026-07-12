import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class NotificationSenderService {
  static const String _baseUrl = 'https://sanad-nine-nu.vercel.app';

  /// Sends a push notification to a target device via the custom local backend.
  Future<bool> sendNotification({
    required String targetFcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/send-notification');
      // ignore: avoid_print
      print('🚀 --- Sending HTTP Request to $_baseUrl ---');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': targetFcmToken,
          'title': title,
          'body': body,
          if (data != null) 'data': data,
        }),
      );

      // ignore: avoid_print
      print('📬 --- Response: ${response.statusCode} - ${response.body} ---');

      if (response.statusCode == 200) {
        log('Notification sent successfully: ${response.body}');
        return true;
      } else {
        log('Failed to send notification. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('🛑 --- Error sending notification: $e ---');
      log('Error sending notification: $e');
      return false;
    }
  }
}
