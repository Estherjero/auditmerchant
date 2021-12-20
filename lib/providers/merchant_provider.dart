import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../utils.dart' as utils;
import 'package:http/http.dart' as http;

class MerchantProvider extends ChangeNotifier {
  final _auth;
  static const _baseUrl = 'account';
  MerchantProvider(this._auth);

  Future<List> getAccountList() async {
    final url = utils.encodeUrl('$_baseUrl/list');
    final response = await http.get(
      url,
      headers: {'X-Auth-Token': _auth.token as String},
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<Map> getAccount(String accountId) async {
    final url = utils.encodeUrl('$_baseUrl/$accountId');
    final response = await http.get(
      url,
      headers: {'X-Auth-Token': _auth.token as String},
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<Map> createAccount(Map data) async {
    final url = utils.encodeUrl('$_baseUrl/create');
    final response = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': _auth.token as String,
      },
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<Map> updateAccount(String accountId, Map data) async {
    final url = utils.encodeUrl('$_baseUrl/$accountId/update');
    final response = await http.put(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': _auth.token as String,
      },
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<Map> applyPattern(String accountId, Map data) async {
    final url = utils.encodeUrl('$_baseUrl/$accountId/apply-pattern');
    final response = await http.put(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': _auth.token as String,
      },
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<void> startAccount(String accountId) async {
    final url = utils.encodeUrl('$_baseUrl/$accountId/start');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': _auth.token as String,
      },
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }

  Future<void> stopAccount(String accountId, Map data) async {
    final url = utils.encodeUrl('$_baseUrl/$accountId/stop');
    final response = await http.post(
      url,
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': _auth.token as String,
      },
    );
    return utils.handleResponse(
      response.statusCode,
      response.body,
    );
  }
}
