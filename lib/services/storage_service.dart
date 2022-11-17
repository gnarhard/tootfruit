import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _fileName = 'storage.json';

  Map<String, dynamic>? cachedStorage;
  Map<String, dynamic>? store;

  bool exists(key) => ((store != null) && (store![key] != null));

  Future get(String key) async {
    final storage = await loadStorage();

    return storage[key];
  }

  Future<void> remove(String key) async {
    final storage = await loadStorage();

    storage.remove(key);

    await _saveStorage(storage);
  }

  Future<void> set(String key, value) async {
    final storage = await loadStorage();

    storage[key] = value;
    DateTime today = DateTime.now();
    storage["${key}_expiration"] = DateTime(today.year, today.month, today.day + 7).toString();

    await _saveStorage(storage);
  }

  Future<bool> deleteStorageFile() async {
    try {
      final file = await _getStorageFile();

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> storageFileExists() async {
    final storageFile = await _getStorageFile();

    if (await storageFile.exists()) {
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> loadStorage() async {
    if (cachedStorage != null) {
      return cachedStorage ?? {};
    }

    var storage = <String, dynamic>{};

    final storageFile = await _getStorageFile();

    if (!await storageFile.exists()) {
      return storage;
    }

    // try {
    final jsonString = await storageFile.readAsString();

    if (jsonString != '') {
      storage = json.decode(jsonString);
    }
    // } catch (err) {
    //   ToastService.error(message: "Failed to store data.", devError: err.toString());
    // }

    cachedStorage = storage;
    store = storage;

    return storage;
  }

  Future<void> _saveStorage(Map<String, dynamic> storage) async {
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
