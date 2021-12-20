import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../utils.dart' as utils;
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  late String _token;

  String get token {
    return _token;
  }

  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    Uri url = utils.encodeUrl('auth/login');
    final response = await http.post(
      url,
      body: json.encode({
        'accessId': username,
        'accessKey': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    final responseData = json.decode(response.body);
    _token = responseData['token'] ?? '';
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }
}
