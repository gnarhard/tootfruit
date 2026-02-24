import 'package:flutter/foundation.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/repositories/toot_repository.dart';
import 'package:tootfruit/repositories/user_repository.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/image_precache_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toot_service.dart';

class DI {
  late IStorageRepository storageRepository;
  late IUserRepository userRepository;
  late ITootRepository tootRepository;
  late IAudioPlayer audioPlayer;
  late NavigationService navigationService;
  late ImagePrecacheService imagePrecacheService;
  late TootService tootService;

  static final DI _instance = DI._internal();
  factory DI() => _instance;
  DI._internal();

  bool _initialized = false;

  void initialize() {
    if (_initialized) {
      debugPrint('Dependencies already initialized.');
      return;
    }

    tootRepository = TootRepository();
    audioPlayer = AudioService();
    navigationService = NavigationService();
    imagePrecacheService = ImagePrecacheService();

    storageRepository = FileStorageRepository();
    userRepository = UserRepository(storageRepository);

    tootService = TootService(
      tootRepository: tootRepository,
      userRepository: userRepository,
      audioPlayer: audioPlayer,
    );

    _initialized = true;
  }

  @visibleForTesting
  void reset() {
    _initialized = false;
  }
}
