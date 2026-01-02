/// Country selection state provider with persistence
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier for managing selected country state
class SelectedCountryNotifier extends StateNotifier<String?> {
  SelectedCountryNotifier() : super(null) {
    _load();
  }

  static const _key = 'selected_country';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        state = saved;
      }
    } catch (_) {
      // Ignore errors access prefs
    }
  }

  Future<void> setCountry(String? countryCode) async {
    state = countryCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (countryCode == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, countryCode);
      }
    } catch (_) {
      // Ignore errors saving
    }
  }
}

/// Provider for the currently selected country code
final selectedCountryProvider = StateNotifierProvider<SelectedCountryNotifier, String?>((ref) {
  return SelectedCountryNotifier();
});
