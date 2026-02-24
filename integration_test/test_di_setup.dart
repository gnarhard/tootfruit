import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/repositories/user_repository.dart';
import 'package:tootfruit/services/toot_service.dart';

/// Initializes a clean DI graph for integration tests using in-memory storage.
Future<DI> initializeIntegrationTestState(
  WidgetTester tester, {
  int initialTootIndex = 0,
}) async {
  resetIntegrationTestDI();

  final di = DI();
  di.initialize();

  final storageRepository = InMemoryStorageRepository();
  final userRepository = UserRepository(storageRepository);

  di.storageRepository = storageRepository;
  di.userRepository = userRepository;
  di.tootService = TootService(
    tootRepository: di.tootRepository,
    userRepository: userRepository,
    audioPlayer: di.audioPlayer,
  );

  await tester.runAsync(() async {
    await di.audioPlayer.init();
    await di.userRepository.loadUser();
    await di.tootService.init();
    await di.tootService.set(di.tootService.all[initialTootIndex]);
  });

  return di;
}

void resetIntegrationTestDI() {
  final di = DI();
  try {
    di.audioPlayer.dispose();
  } catch (_) {
    // No-op when dependencies are not initialized for this test run.
  }
  di.reset();
}

class InMemoryStorageRepository implements IStorageRepository {
  final Map<String, dynamic> _storage = <String, dynamic>{};

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<bool> exists(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<T?> get<T>(String key) async {
    return _storage[key] as T?;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> set(String key, dynamic value) async {
    _storage[key] = value;
  }
}
