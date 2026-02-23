import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Colors, Color;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tootfruit/interfaces/i_toast_service.dart';

/// 🍞
/// Concrete implementation of toast notification service
class ToastService implements IToastService {
  static const Duration short = Duration(seconds: 2);
  static const Duration long = Duration(seconds: 4);

  final Color colorError;
  final Color colorErrorText;
  final Color colorWarning;
  final Color colorWarningText;
  final Color colorSuccess;
  final Color colorSuccessText;

  ToastService({
    this.colorError = Colors.red,
    this.colorSuccess = Colors.green,
    this.colorWarning = Colors.yellow,
    this.colorErrorText = Colors.white,
    this.colorSuccessText = Colors.white,
    this.colorWarningText = Colors.black54,
  });

  @override
  void error(String message, {String? devError, response}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    message = (devError == null) ? message : "$message $devError";
    message = (response == null)
        ? message
        : "$message ${response.statusCode}: ${response.reasonPhrase}";
    debugPrint(message);

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: colorError,
        textColor: colorErrorText,
        fontSize: 16.0);
  }

  @override
  void success(String message) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    debugPrint(message);

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: colorSuccess,
        textColor: colorSuccessText,
        fontSize: 16.0);
  }

  @override
  void warning(String message) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    debugPrint(message);

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: colorWarning,
        textColor: colorWarningText,
        fontSize: 16.0);
  }
}
