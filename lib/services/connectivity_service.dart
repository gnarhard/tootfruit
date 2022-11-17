import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  // Other options: mobile, wifi, none.
  final connectivityState$ = BehaviorSubject<ConnectivityResult>.seeded(ConnectivityResult.none);
  final _connectivity = Connectivity();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> init() async {
    _connectivity.onConnectivityChanged.distinct().listen((ConnectivityResult connectionStatus) {
      if (kDebugMode) {
        print('Connectivity changed to: $connectionStatus');
      }

      connectivityState$.add(connectionStatus);

      if (connectionStatus == ConnectivityResult.none) {
        // _navService.current.pushNamed(NoInternetScreen.route);
      }
    });
  }
}
