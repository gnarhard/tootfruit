/// Toast notification service interface
/// Allows different notification implementations
abstract class IToastService {
  /// Show an error message
  void error(String message, {String? devError, dynamic response});

  /// Show a success message
  void success(String message);

  /// Show a warning message
  void warning(String message);
}
