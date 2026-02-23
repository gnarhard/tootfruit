/// Storage keys used throughout the application
class StorageKeys {
  StorageKeys._();

  /// User data storage key
  static const String user = 'user';

  /// Returns the expiration key for a given storage key
  static String expirationKey(String key) => '${key}_expiration';
}
