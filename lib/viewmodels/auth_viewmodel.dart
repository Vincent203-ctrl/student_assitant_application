/**
 * student name: Sinekhaya Vatsha/ 
 * studentNo: 222044842/
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  ProfileModel? _profile;
  String? _errorMessage;

  AuthState get state => _state;
  ProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isAdmin => _profile?.isAdmin ?? false;

  AuthViewModel() {
    _init();
  }

  Future<void> _init() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      await _loadProfile(user.id);
    } else {
      _state = AuthState.unauthenticated;
      notifyListeners();
    }

    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _loadProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _profile = null;
        _state = AuthState.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      _profile = await SupabaseService.fetchProfile(userId);
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadProfile(response.user!.id);
        return true;
      }
      _errorMessage = 'Login failed. Please try again.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required int yearOfStudy,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentNumber: studentNumber,
        role: 'student',
        yearOfStudy: yearOfStudy,
      );

      if (response.user != null) {
        await _loadProfile(response.user!.id);
        return true;
      }
      _errorMessage = 'Registration failed.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _profile = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
