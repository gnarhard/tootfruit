/// Storage repository interface for dependency inversion
/// Allows different storage implementations (file, memory, cloud, etc.)
abstract class IStorageRepository {
  /// Check if a key exists in storage
  Future<bool> exists(String key);

  /// Get a value from storage
  Future<T?> get<T>(String key);

  /// Set a value in storage
  Future<void> set(String key, dynamic value);

  /// Remove a value from storage
  Future<void> remove(String key);

  /// Clear all storage
  Future<void> clear();
}
