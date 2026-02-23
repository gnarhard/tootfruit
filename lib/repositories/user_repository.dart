import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/models/settings.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';

/// Concrete implementation of user repository
/// Single responsibility: User data persistence
class UserRepository implements IUserRepository {
  final IStorageRepository _storage;
  User? _currentUser;

  UserRepository(this._storage);

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> loadUser() async {
    final userJson = await _storage.get<dynamic>(StorageKeys.user);

    if (userJson == null) {
      _currentUser = User(settings: Settings());
    } else {
      if (userJson is User) {
        _currentUser = userJson;
      } else {
        _currentUser = User.fromJson(userJson);
      }
    }

    final allFruitNames = toots.map((toot) => toot.fruit).toList();
    _currentUser!.ownedFruit = allFruitNames;
    if (!allFruitNames.contains(_currentUser!.currentFruit)) {
      _currentUser!.currentFruit = allFruitNames.first;
    }

    await saveUser(_currentUser!);
    return _currentUser!;
  }

  @override
  Future<void> saveUser(User user) async {
    _currentUser = user;
    await _storage.set(StorageKeys.user, user);
  }

  @override
  Future<void> updateCurrentFruit(String fruit) async {
    if (_currentUser == null) {
      throw StateError('User must be loaded before updating');
    }
    _currentUser!.currentFruit = fruit;
    await saveUser(_currentUser!);
  }

  @override
  Future<void> addOwnedFruit(String fruit) async {
    if (_currentUser == null) {
      throw StateError('User must be loaded before updating');
    }
    _currentUser!.ownedFruit.add(fruit);
    await saveUser(_currentUser!);
  }

  @override
  Future<void> setAllFruitsOwned(List<String> fruits) async {
    if (_currentUser == null) {
      throw StateError('User must be loaded before updating');
    }
    _currentUser!.ownedFruit = fruits;
    await saveUser(_currentUser!);
  }
}
