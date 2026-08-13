import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kite/features/profile/domain/user_profile.dart';
import 'package:kite/shared/networks/jwt_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final http.Client _client;
  final JwtService _jwtService;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileProvider(this._client, this._jwtService);

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/kite/api/v1/user-profile';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/kite/api/v1/user-profile';
    return 'http://localhost:8080/kite/api/v1/user-profile';
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _jwtService.getToken();
      final response = await _client.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to load user profile (${response.statusCode})';
        notifyListeners();
      }
    } on SocketException {
      _isLoading = false;
      _errorMessage = 'Cannot connect to server. Please check your backend connection.';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
