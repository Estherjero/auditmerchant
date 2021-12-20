import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Uri encodeUrl(String path) {
  String _domain = '';
  if (kDebugMode) {
    _domain = '192.168.1.37:3000';
    return Uri.http(_domain, path);
  } else {
    _domain = 'vel.auditplus.io';
    return Uri.https(_domain, path);
  }
}

void handleErrorResponse(BuildContext context, dynamic message) {
  if (message.contains('Unauthorized'))
    Navigator.of(context).pushReplacementNamed('/login');
  else
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.contains('Failed host lookup')
              ? 'Please check your internet connection!'
              : message,
          style: Theme.of(context).textTheme.button,
        ),
        backgroundColor: Theme.of(context).errorColor,
      ),
    );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).primaryColor,
    ),
  );
}

dynamic handleResponse(int statusCode, dynamic responseData) {
  var response;
  switch (statusCode) {
    case 200:
      response = responseData.isNotEmpty ? json.decode(responseData) : {};
      return response;
    case 201:
      response = responseData.isNotEmpty ? json.decode(responseData) : {};
      return response;
    case 401:
      response = {'message': 'Unauthorized'};
      throw HttpException(response['message']);
    default:
      response = json.decode(responseData);
      throw HttpException(response['message'] is List
          ? response['message'].join(',')
          : response['message']);
  }
}
