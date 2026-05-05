import 'dart:convert';
import 'package:http/http.dart' as http;

// ================= CONFIG =================

const BASE_EMAIL = "http://127.0.0.1:5000";
const BASE_MALWARE = "http://127.0.0.1:5001";
const BASE_URL = "http://127.0.0.1:5003";
// ================= EMAIL =================

Future<Map<String, dynamic>> getEmail() async {
  final response =
      await http.get(Uri.parse('$BASE_EMAIL/get_latest'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed");
  }
} 

// ================= MALWARE =================

// ▶️ Start watcher
Future startWatcher() async {
  await http.post(
    Uri.parse('$BASE_MALWARE/api/watcher/start'),
  );
}

// ⛔ Stop watcher
Future stopWatcher() async {
  await http.post(
    Uri.parse('$BASE_MALWARE/api/watcher/stop'),
  );
}

// 📊 Get reports
Future<Map<String, dynamic>> getReports() async {
  final res = await http.get(
    Uri.parse('$BASE_MALWARE/api/reports?limit=10'),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Failed to load reports");
  }
}

// url 
Future<Map<String, dynamic>> scanUrl(String url) async {
  final res = await http.post(
    Uri.parse('http://127.0.0.1:5002/api/scan_url'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"url": url}),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("URL scan failed");
  }
} 


Future<Map<String, dynamic>> verifyUsbPassword(String password) async {
  final res = await http.post(
    Uri.parse('http://127.0.0.1:5003/verify'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"password": password}),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Verification failed");
  }
}

Future<List<dynamic>> getUsbLogs() async {
  final res = await http.get(
    Uri.parse('$BASE_URL/logs'),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Failed to load logs");
  }
}

// ================= CHATBOT =================

Future<String> sendChatMessage(String message) async {
  final res = await http.post(
    Uri.parse("http://127.0.0.1:5004/api/chat"), // ✅ correct port
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "message": message,
      "session_id": "user1"
    }),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data["reply"];
  } else {
    return "Error: ${res.body}";
  }
}