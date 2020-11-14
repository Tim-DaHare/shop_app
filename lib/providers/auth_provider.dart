import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _tokenExpiryDate;
  String _userId;

  Timer _authTimer;

  final BuildContext provContext;

  AuthProvider({@required this.provContext});

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
      _autoLogout();

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final authPrefsString = jsonEncode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _tokenExpiryDate.toIso8601String(),
      });

      await prefs.setString("auth", authPrefsString);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("auth")) return false;

    final authData = jsonDecode(prefs.getString("auth")) as Map<String, Object>;
    final expiryDate = DateTime.parse(authData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = authData["token"];
    _userId = authData["userId"];
    _tokenExpiryDate = expiryDate;
    notifyListeners();

    _autoLogout();
    return true;
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
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final authPrefsString = jsonEncode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _tokenExpiryDate.toIso8601String(),
      });

      await prefs.setString("auth", authPrefsString);
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _tokenExpiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("auth");
  }

  // function that handles user logout when token is expired
  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final secondsTillExpiry =
        _tokenExpiryDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(
      Duration(seconds: secondsTillExpiry),
      logout,
    );
  }
}
