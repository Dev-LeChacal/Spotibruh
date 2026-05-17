import "package:spotibruh/widgets/messenger.dart";

class Utils {
  Utils._();

  static T guard<T>(T? value) {
    if (value == null) throw Exception("Unexpected null");
    return value;
  }

  static Future<T> tryCatch<T>(
    Future<T> Function() action, {

    void Function(Object e)? onError,

    String? onErrorMessage,
    String? onSuccessMessage,

    required T fallback,
  }) async {
    try {
      return await action();

      // catch
    } catch (e) {
      if (onErrorMessage != null) {
        Messenger.show(onErrorMessage, type: MessageType.error, error: e);
      }

      if (onError != null) {
        onError.call(e);
      }

      return fallback;

      // finally
    } finally {
      if (onSuccessMessage != null) {
        Messenger.show(onSuccessMessage, type: MessageType.success);
      }
    }
  }

  static void noop([bool value = false]) {}
}
