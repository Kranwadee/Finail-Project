import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String baseUrl =
      'https://yourapiurl.com/api'; // เปลี่ยนเป็น URL API ของคุณ

  static Future<dynamic> fetchActivities() async {
    final response = await http.get(Uri.parse('$baseUrl/activities'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('ไม่สามารถโหลดกิจกรรมได้');
    }
  }

  static Future<void> joinActivity(String userId, String activityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/join'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'activityId': activityId}),
    );
    if (response.statusCode != 200) {
      throw Exception('ไม่สามารถเข้าร่วมกิจกรรมได้');
    }
  }

  static Future<void> leaveActivity(String userId, String activityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'activityId': activityId}),
    );
    if (response.statusCode != 200) {
      throw Exception('ไม่สามารถออกจากกิจกรรมได้');
    }
  }
}
