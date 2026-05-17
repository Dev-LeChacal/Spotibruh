import "package:flutter_dotenv/flutter_dotenv.dart";

class Env {
  Env._();

  static String getClientId() {
    return dotenv.env["CLIENT_ID"] ?? "";
  }

  static String getRedirectUri() {
    return "spotibruh://callback";
  }
}
