import 'package:toot_fruit/services/storage_service.dart';

import '../locator.dart';
import '../models/settings.dart';
import '../models/user.dart';

class UserService {
  late final _storageService = Locator.get<StorageService>();

  User? current;

  Future<int> get money async => await _storageService.get('chestMoney');

  Future<User> init() async {
    final userJson = await _storageService.get('user');

    if (userJson == null) {
      current = User(settings: Settings());
    } else {
      if (userJson is User) {
        current = userJson;
      } else {
        current = User.fromJson(userJson);
      }
    }

    await _storageService.set('user', current!);

    return current!;
  }
}
