import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlService {
  void launch(String url, bool webView) async {
    Uri uri = Uri.parse(url);

    canLaunchUrl(uri).then((bool result) async {
      if (result) {
        bool launched = await launchUrl(uri,
            mode: (webView) ? LaunchMode.inAppWebView : LaunchMode.platformDefault);
        if (launched) {
          return;
        }
      }

      Fluttertoast.showToast(
          msg: "Failed to launch $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
