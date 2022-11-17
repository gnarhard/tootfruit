import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../locator.dart';
import 'connectivity_service.dart';

class ToastService {
  // 🍞
  static error({required String message, String? devError, response}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    final connectivityService = Locator.get<ConnectivityService>();

    if (connectivityService.connectivityState$.value == ConnectivityResult.none) {
      message = 'No internet connection';
    } else if (kDebugMode) {
      message = (devError == null) ? message : "$message $devError";
      message = (response == null)
          ? message
          : "$message ${response.statusCode}: ${response.reasonPhrase}";
      print(message);
    }

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static success({required message}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    if (kDebugMode) {
      print(message);
    }

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static warning({required message}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    if (kDebugMode) {
      print(message);
    }

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.yellow,
        textColor: Colors.black54,
        fontSize: 16.0);
  }
}
