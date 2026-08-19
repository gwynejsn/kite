import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kite/features/profile/domain/user_profile.dart';
import 'package:kite/shared/enums/gender.dart';
import 'package:kite/shared/enums/preferred_theme.dart';

class UserProfileProvider extends ChangeNotifier {
  final Dio _dio;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileProvider(this._dio);

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ThemeMode get themeMode {
    final theme = _userProfile?.preferredTheme;
    switch (theme) {
      case PreferredTheme.light:
        return ThemeMode.light;
      case PreferredTheme.dark:
      case null:
        return ThemeMode.dark;
    }
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/user-profile');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(data);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to load user profile (${response.statusCode})';
        notifyListeners();
      }
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _extractErrorMessage(
        e,
        fallback: 'Failed to load user profile',
      );
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String profileImageLink,
    required String bio,
    required Gender gender,
    required PreferredTheme preferredTheme,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'profileImageLink': profileImageLink,
        'bio': bio,
        'gender': gender.name.toUpperCase(),
        'preferredTheme': preferredTheme.name.toUpperCase(),
      };

      final response = await _dio.put('/user-profile', data: body);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(data);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage =
            'Failed to update user profile (${response.statusCode})';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _extractErrorMessage(
        e,
        fallback: 'Failed to update user profile',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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

  String _extractErrorMessage(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your backend connection.';
    }
    if (e.response?.data is Map &&
        (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }
    return fallback;
  }
}
