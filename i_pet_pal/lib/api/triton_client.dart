import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:i_pet_pal/env/env.dart';

class TritonClient {
  static const headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "pal-ette-pass": Env.palEtteApiKey,
  };
  static Future<bool> ping(String baseUrl) async {
    final url = Uri.parse("$baseUrl/health/ready");
    final response = await http.get(url, headers: headers);
    return response.statusCode == 200;
  }

  static Future<List<(String, double)>> inference(
      String baseUrl, String modelName, String body) async {
    final url = Uri.parse("$baseUrl/models/$modelName/infer");
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200) {
      return List<(String, double)>.empty();
    }

    final responseBody = json.decode(utf8.decode(response.bodyBytes));
    final result = List<(String, double)>.from(
        responseBody["outputs"][0]["data"].map((data) {
      final c = data.split(":");
      return (c[2].trim(), double.parse(c[0]));
    }));
    final values = result.map((e) => e.$2);
    final softmaxValues = softmax(values.toList());
    return List<(String, double)>.generate(
      result.length,
      (index) => (result[index].$1, softmaxValues[index]),
    );
  }

  static List<double> softmax(List<double> list) {
    final C = list.reduce(max);
    final d = list.map((y) => exp(y - C)).reduce((a, b) => a + b);
    return list.map((value) {
      return exp(value - C) / d;
    }).toList();
  }
}
