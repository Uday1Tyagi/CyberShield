import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static String baseUrl = "http://localhost:8000";

  static Future sendOtp(String email) async {

    var response = await http.post(

      Uri.parse("$baseUrl/send_otp?email=$email")

    );

    return jsonDecode(response.body);

  }

  static Future verifyOtp(String email,String otp,String password) async {

    var response = await http.post(

      Uri.parse(

"$baseUrl/verify_otp?email=$email&otp=$otp&password=$password"

      )

    );

    return jsonDecode(response.body);

  }

  static Future login(String email,String password) async {

    var response = await http.post(

      Uri.parse(

"$baseUrl/login?email=$email&password=$password"

      )

    );

    return jsonDecode(response.body);

  }

}