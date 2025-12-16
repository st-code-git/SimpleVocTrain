import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/app_language.dart'; // Importieren Sie Ihre Modelle hier

class LanguageService extends ChangeNotifier {
  // Lokaler State
  AppLanguage _lang1 = AppLanguage(label: 'Deutsch');
  AppLanguage _lang2 = AppLanguage(label: 'English');
  AppLanguage _lang3 = AppLanguage(label: 'Español');
  
  bool _isLoading = true;

  // Getter
  AppLanguage get lang1 => _lang1;
  AppLanguage get lang2 => _lang2;
  AppLanguage get lang3 => _lang3;
  bool get isLoading => _isLoading;

  // Getter für Dropdowns (Alle verfügbaren Sprachen als Liste)
  List<AppLanguage> get all => [_lang1, _lang2, _lang3];

  // 1. Laden der Daten (z.B. beim App Start in main.dart aufrufen)
  Future<void> loadLanguages() async {
    _isLoading = true;
    notifyListeners(); // UI zeigen, dass geladen wird

    final data = await SupabaseService.instance.loadUserLanguages();

    if (data != null) {
      _lang1 = AppLanguage(label: data.language1);
      _lang2 = AppLanguage(label: data.language2);
      _lang3 = AppLanguage(label: data.language3);
    }
    
    _isLoading = false;
    notifyListeners(); // WICHTIG: Alle Widgets informieren!
  }

  // 2. Speichern der Daten
  Future<bool> updateLanguages(String l1, String l2, String l3) async {
    // Optimistisches Update im State
    _lang1 = AppLanguage(label: l1);
    _lang2 = AppLanguage(label: l2);
    _lang3 = AppLanguage(label: l3);
    notifyListeners(); // UI sofort aktualisieren

    // Speichern in Supabase
    final success = await SupabaseService.instance.saveUserLanguages(
      lang1: _lang1,
      lang2: _lang2,
      lang3: _lang3,
    );

    return success;
  }
}