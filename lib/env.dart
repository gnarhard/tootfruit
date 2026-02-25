class Env {
  static const String title = 'Toot Fruit';
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const siteUrl = 'https://gnarhard.com'; // No trailing slash, please.
  Env._();
}
