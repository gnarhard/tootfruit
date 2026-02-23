import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/services/storage_service.dart';

import '../locator.dart';
import '../models/settings.dart';
import '../models/user.dart';

class UserService {
  late final _storageService = Locator.get<StorageService>();

  User? current;

  Future<int> get money async => await _storageService.get('chestMoney');

  Future<User> init() async {
    final userJson = await _storageService.get(StorageKeys.user);

    if (userJson == null) {
      current = User(settings: Settings());
    } else {
      if (userJson is User) {
        current = userJson;
      } else {
        current = User.fromJson(userJson);
      }
    }

    // All fruits are now available immediately on every platform.
    final allFruitNames = toots.map((toot) => toot.fruit).toList();
    current!.ownedFruit = allFruitNames;
    if (!allFruitNames.contains(current!.currentFruit)) {
      current!.currentFruit = allFruitNames.first;
    }

    await _storageService.set(StorageKeys.user, current!);

    return current!;
  }
}
