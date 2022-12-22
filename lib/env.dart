class Env {
  static const String title = 'Toot Fruit';
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const prodUrl = 'https://gnarhard.dev'; // No trailing slash, please.
  static const devUrl = 'https://gnarhard.dev'; // No trailing slash, please.
  static const String siteUrl = isProduction ? prodUrl : devUrl;
  Env._();
}
