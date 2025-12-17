import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/app_language.dart'; 

class LanguageService extends ChangeNotifier {
  AppLanguage _lang1 = AppLanguage(label: 'Deutsch');
  AppLanguage _lang2 = AppLanguage(label: 'English');
  AppLanguage _lang3 = AppLanguage(label: 'Español');
  
  bool _isLoading = true;

  AppLanguage get lang1 => _lang1;
  AppLanguage get lang2 => _lang2;
  AppLanguage get lang3 => _lang3;
  bool get isLoading => _isLoading;

  List<AppLanguage> get all => [_lang1, _lang2, _lang3];

  Future<void> loadLanguages() async {
    _isLoading = true;
    notifyListeners(); 

    final data = await SupabaseService.instance.loadUserLanguages();

    if (data != null) {
      _lang1 = AppLanguage(label: data.language1);
      _lang2 = AppLanguage(label: data.language2);
      _lang3 = AppLanguage(label: data.language3);
    }
    
    _isLoading = false;
    notifyListeners(); 
  }

  Future<bool> updateLanguages(String l1, String l2, String l3) async {

    _lang1 = AppLanguage(label: l1);
    _lang2 = AppLanguage(label: l2);
    _lang3 = AppLanguage(label: l3);
    notifyListeners(); 

    final success = await SupabaseService.instance.saveUserLanguages(
      lang1: _lang1,
      lang2: _lang2,
      lang3: _lang3,
    );

    return success;
  }
}