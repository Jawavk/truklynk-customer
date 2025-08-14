import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';

class TokenService {
  String _isIntroKey = "isIntro";
  String _isUser = "isUser";
  String _FCMToken = "FCMToken";

  final storage = const FlutterSecureStorage();

  Future<String?> getIntro() async {
    try {
      return await storage.read(key: _isIntroKey);
    } catch (e) {
      // Handle exceptions or log errors
      return null;
    }
  }

  Future<void> saveIntro(String value) async {
    try {
      await storage.write(key: _isIntroKey, value: value);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<void> clearIntro() async {
    try {
      await storage.delete(key: _isIntroKey);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<void> saveUser(String value) async {
    try {
      await storage.write(key: _isUser, value: value);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<Createuser?> getUser() async {
    try {
      // return await storage.read(key: _isUser);
      String response = '${await storage.read(key: _isUser)}';
      response = response.replaceAllMapped(
          RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');
      response = response.replaceAllMapped(
          RegExp(r': ([0-9]+)'), (match) => ': ${match.group(1)}');
      response = response.replaceAllMapped(
          RegExp(r': ([^,\}]+)'), (match) => ': "${match.group(1)}"');
      var decodedJson = jsonDecode(response);
      decodedJson['code'] = int.tryParse(decodedJson['code'].toString());
      decodedJson['users_sno'] =
          int.tryParse(decodedJson['users_sno'].toString());
      decodedJson['user_profile_sno'] =
          int.tryParse(decodedJson['user_profile_sno'].toString());
      decodedJson['signinconfig_sno'] =
          int.tryParse(decodedJson['signinconfig_sno'].toString());
      return Createuser.fromJson(decodedJson);
    } catch (e) {
      // Handle exceptions or log errors
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await storage.delete(key: _isUser);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<void> clearAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<void> saveFCMToken(String value) async {
    try {
      await storage.write(key: _FCMToken, value: value);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await storage.read(key: _FCMToken);
    } catch (e) {
      // Handle exceptions or log errors
      return null;
    }
  }

  Future<void> clearFCMToken() async {
    try {
      await storage.delete(key: _FCMToken);
    } catch (e) {
      // Handle exceptions or log errors
    }
  }
}
