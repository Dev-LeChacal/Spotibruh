import "package:flutter/material.dart";
import "package:spotibruh/app.dart";
import "package:spotibruh/router.dart";
import "package:spotibruh/routes.dart";
import "package:spotibruh/services/auth/youtube.dart";
import "package:webview_flutter/webview_flutter.dart" hide WebViewCookieManager;
import "package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart";

class YoutubeLoginScreen extends StatefulWidget {
  const YoutubeLoginScreen({super.key});

  @override
  State<YoutubeLoginScreen> createState() => _YoutubeLoginScreenState();
}

class _YoutubeLoginScreenState extends State<YoutubeLoginScreen> {
  static Uri get _googleAccounts => Uri.parse("https://accounts.google.com/signin");

  late final WebViewController _controller;

  bool _cookiesSaved = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();

    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller.setUserAgent(
      "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36",
    );

    _controller.setNavigationDelegate(NavigationDelegate(onPageFinished: _onPageFinished));

    _controller.loadRequest(_googleAccounts);
  }

  void _onPageFinished(String url) async {
    if (url.contains("myaccount.google.com")) {
      _controller.loadRequest(Uri.parse("https://www.youtube.com"));

      // if youtube
    } else if (url.contains("youtube.com") && !_cookiesSaved) {
      _cookiesSaved = true;

      final cookies = await WebviewCookieManager().getCookies("https://youtube.com");
      final cookieString = cookies.map((c) => "${c.name}=${c.value}").join("; ");

      await YoutubeAuth.saveCookies(cookieString);

      router.go(Routes.auth.root);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),

          child: ClipRRect(
            borderRadius: App.borderRadius,
            child: WebViewWidget(controller: _controller),
          ),
        ),
      ),
    );
  }
}
