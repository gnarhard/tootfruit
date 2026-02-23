import 'package:tootfruit/services/ad_service.dart';

class NewFruitAdService extends AdService {
  NewFruitAdService({
    required super.androidAppId,
    required super.iosAppId,
    super.isDebugMode = false,
  });

  Future<void> Function()? callback;

  Future<void> reward(void Function() callback) async => callback();
}
