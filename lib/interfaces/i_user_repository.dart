import 'package:tootfruit/models/user.dart';

/// User repository interface following Repository Pattern
/// Separates data access logic from business logic
abstract class IUserRepository {
  /// Get the current user
  User? get currentUser;

  /// Load user from storage
  Future<User> loadUser();

  /// Save user to storage
  Future<void> saveUser(User user);

  /// Update current fruit for user
  Future<void> updateCurrentFruit(String fruit);

  /// Add a fruit to user's owned fruits
  Future<void> addOwnedFruit(String fruit);

  /// Set all fruits as owned
  Future<void> setAllFruitsOwned(List<String> fruits);
}
