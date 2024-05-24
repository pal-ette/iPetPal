import 'package:http/http.dart' as http;

class TritonClient {
  static Future<bool> ping(String baseUrl) async {
    final url = Uri.parse("$baseUrl/health/ready");
    final response = await http.get(url);
    return response.statusCode == 200;
  }
}
