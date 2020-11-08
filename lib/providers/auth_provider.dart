import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _tokenExpiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_tokenExpiryDate == null ||
        _tokenExpiryDate.isBefore(DateTime.now()) ||
        _token == null) {
      return null;
    }
    return _token;
  }

  Future<void> signUp(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBdj9OpcmdI92T1fcSBAysdPLaoszqIkvw";

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      if (response.statusCode >= 300) {
        throw HttpException("Register failed");
      }

      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _tokenExpiryDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData["expiresIn"])),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBdj9OpcmdI92T1fcSBAysdPLaoszqIkvw";

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      if (response.statusCode >= 300) {
        throw HttpException("Login failed");
      }

      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _tokenExpiryDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData["expiresIn"])),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
