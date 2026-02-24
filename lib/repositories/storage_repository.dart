import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';

/// File-based storage repository implementation
/// Single responsibility: File-based data persistence
class FileStorageRepository implements IStorageRepository {
  static const _fileName = 'storage.json';
  static const _cacheExpirationDays = Duration(days: 1);

  Map<String, dynamic>? _cachedStorage;

  DateTime get _expirationDate => DateTime.now().add(_cacheExpirationDays);

  DateTime _setNewExpirationDate(DateTime expiration) => DateTime(
    expiration.year,
    expiration.month,
    expiration.day,
  ).add(_cacheExpirationDays);

  @override
  Future<bool> exists(String key) async {
    final storage = await _loadStorage();

    if (storage[key] == null) {
      return false;
    }

    final expirationKey = StorageKeys.expirationKey(key);
    final cacheInvalidationDate = storage[expirationKey] as String?;

    if (cacheInvalidationDate == null) {
      return false;
    }

    final expiration = DateTime.parse(cacheInvalidationDate);
    return !_isStale(expiration);
  }

  @override
  Future<T?> get<T>(String key) async {
    final storage = await _loadStorage();
    return storage[key] as T?;
  }

  @override
  Future<void> set(String key, dynamic value) async {
    final storage = await _loadStorage();
    storage[key] = value;
    storage[StorageKeys.expirationKey(key)] = _expirationDate.toString();
    await _saveStorage(storage);
  }

  @override
  Future<void> remove(String key) async {
    final storage = await _loadStorage();
    storage.remove(key);
    storage.remove(StorageKeys.expirationKey(key));
    await _saveStorage(storage);
  }

  @override
  Future<void> clear() async {
    _cachedStorage = {};
    await _saveStorage({});
  }

  bool _isStale(DateTime expiration) {
    return expiration.isAfter(_setNewExpirationDate(expiration));
  }

  Future<Map<String, dynamic>> _loadStorage() async {
    if (_cachedStorage != null) {
      return _cachedStorage!;
    }

    final storageFile = await _getStorageFile();

    if (!await storageFile.exists()) {
      _cachedStorage = {};
      return _cachedStorage!;
    }

    try {
      final jsonString = await storageFile.readAsString();
      _cachedStorage = jsonString.isEmpty ? {} : json.decode(jsonString);
    } catch (err) {
      debugPrint('FileStorageRepository: Failed to load data: $err');
      _cachedStorage = {};
    }

    return _cachedStorage!;
  }

  Future<void> _saveStorage(Map<String, dynamic> storage) async {
    final jsonString = json.encode(storage);
    final storageFile = await _getStorageFile();

    if (!await storageFile.exists()) {
      await storageFile.create();
    }

    await storageFile.writeAsString(jsonString);
    _cachedStorage = storage;
  }

  Future<File> _getStorageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Delete the storage file (for debug purposes)
  Future<bool> deleteStorageFile() async {
    try {
      final file = await _getStorageFile();
      await file.delete();
      _cachedStorage = null;
      return true;
    } catch (e) {
      return false;
    }
  }
}
