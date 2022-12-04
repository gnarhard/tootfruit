import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/services/storage_service.dart';

import '../locator.dart';
import '../models/settings.dart';
import '../models/user.dart';

class UserService {
  late final _storageService = Locator.get<StorageService>();

  final current$ = BehaviorSubject<User?>.seeded(null);
  Future<int> get money async => await _storageService.get('chestMoney');

  Future<void> init() async {
    // _storageService.deleteStorageFile();
    final userJson = await _storageService.get('user');
    late User user;

    if (userJson == null) {
      user = User(settings: Settings());
    } else {
      user = User.fromJson(userJson);
    }

    current$.add(user);
    current$.listen((user) async {
      await _storageService.set('user', user!.toJson());
    });
  }
}
