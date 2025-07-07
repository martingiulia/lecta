import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _hasSeenOnboarding = false;
  bool _isLoading = true;
  bool _hasLoggedIn = false;

  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoading => _isLoading;
  bool get hasLoggedIn => _hasLoggedIn;

  /// Inizializza il provider caricando lo stato salvato
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      _hasLoggedIn = prefs.getBool('has_logged_in') ?? false;
    } catch (e) {
      // In caso di errore, mantieni il valore di default
      _hasSeenOnboarding = false;
      _hasLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completa l'onboarding e salva lo stato
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      _hasSeenOnboarding = true;
      notifyListeners();
    } catch (e) {
      // Gestisci l'errore se necessario
      debugPrint('Errore nel salvare lo stato dell\'onboarding: $e');
    }
  }

  /// Completa il login e salva lo stato
  Future<void> completeLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in', true);
      _hasLoggedIn = true;
      notifyListeners();
    } catch (e) {
      // Gestisci l'errore se necessario
      debugPrint('Errore nel salvare lo stato del login: $e');
    }
  }

  /// Reset dell'onboarding e login (utile per testing)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_seen_onboarding');
      await prefs.remove('has_logged_in');
      _hasSeenOnboarding = false;
      _hasLoggedIn = false;
      notifyListeners();
    } catch (e) {
      // Gestisci l'errore se necessario
      debugPrint('Errore nel reset dell\'onboarding: $e');
    }
  }
}
