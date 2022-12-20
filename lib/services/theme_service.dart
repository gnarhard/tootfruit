import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:toot_fruit/locator.dart';
import 'package:toot_fruit/services/storage_service.dart';

class ThemeService {
  late final _storageService = Locator.get<StorageService>();
  final current$ = BehaviorSubject<ThemeMode>.seeded(ThemeMode.dark);

  Future<void> init() async {
    final storedTheme = await _storageService.get('app_theme');
    if (storedTheme == null) {
      return;
    }

    current$.add(storedTheme);
  }
}
