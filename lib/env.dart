class Env {
  static const String title = 'Stink Peach';
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const prodUrl = 'https://stinkpeach.com'; // No trailing slash, please.
  static const devUrl = 'https://stinkpeach.com'; // No trailing slash, please.
  static const String siteUrl = isProduction ? prodUrl : devUrl;
  Env._();
}
