import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/locator.dart';

class StorageService {
  late final _toastService = Locator.get<ToastService>();

  static const _fileName = 'storage.json';

  static const _cacheExpirationDays = Duration(days: 1);

  Map<String, dynamic>? cachedStorage;

  DateTime get _expirationDate => DateTime.now().add(_cacheExpirationDays);

  DateTime _setNewExpirationDate(DateTime expiration) => DateTime(
    expiration.year,
    expiration.month,
    expiration.day,
  ).add(_cacheExpirationDays);

  /// Checks first if data and store exists then checks if the cache is expired and wipes data if it is.
  bool exists(String key) {
    if ((cachedStorage == null) || (cachedStorage![key] == null)) {
      return false;
    }

    String? cacheInvalidationDate =
        cachedStorage![StorageKeys.expirationKey(key)];
    if (cacheInvalidationDate == null) {
      return false;
    }

    DateTime expiration = DateTime.parse(cacheInvalidationDate);
    final cacheIsStale = isStale(key, expiration);

    return !cacheIsStale;
  }

  bool isStale(String key, DateTime expiration) {
    if (expiration.isAfter(_setNewExpirationDate(expiration))) {
      invalidateCache(key);
      return true;
    }

    return false;
  }

  void invalidateCache(String key) {
    remove(key);
    remove(StorageKeys.expirationKey(key));
  }

  Future get(String key) async {
    final storage = await loadStorage();
    return storage[key];
  }

  Future<void> remove(String key) async {
    final storage = await loadStorage();

    storage.remove(key);

    await _saveStorage(storage);
  }

  Future<void> set(String key, dynamic value) async {
    final storage = await loadStorage();

    storage[key] = value;
    storage[StorageKeys.expirationKey(key)] = _expirationDate.toString();

    await _saveStorage(storage);
  }

  Future<bool> deleteStorageFile() async {
    if (kIsWeb) {
      cachedStorage = <String, dynamic>{};
      return true;
    }

    try {
      final file = await _getStorageFile();

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> storageFileExists() async {
    if (kIsWeb) {
      return cachedStorage != null && cachedStorage!.isNotEmpty;
    }

    final storageFile = await _getStorageFile();
    return await storageFile.exists();
  }

  Future<Map<String, dynamic>> loadStorage() async {
    if (cachedStorage != null) {
      return cachedStorage ?? {};
    }

    var storage = <String, dynamic>{};

    if (kIsWeb) {
      cachedStorage = storage;
      return storage;
    }

    final storageFile = await _getStorageFile();

    if (!await storageFile.exists()) {
      return storage;
    }

    try {
      final jsonString = await storageFile.readAsString();

      if (jsonString != '') {
        storage = json.decode(jsonString);
      }
    } catch (err) {
      _toastService.error("Failed to store data.", devError: err.toString());
    }

    cachedStorage = storage;
    return storage;
  }

  Future<void> _saveStorage(Map<String, dynamic> storage) async {
    if (kIsWeb) {
      cachedStorage = storage;
      return;
    }

    final jsonString = json.encode(storage);
    final storageFile = await _getStorageFile();

    if (!await storageFile.exists()) {
      await storageFile.create();
    }

    await storageFile.writeAsString(jsonString);

    cachedStorage = storage;
  }

  Future<File> _getStorageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}
