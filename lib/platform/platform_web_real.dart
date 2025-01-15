// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'platform_interface.dart';

class WebPlatform implements PlatformInterface {
  const WebPlatform();

  @override
  Future<void> launchURL(String url) async {
    html.window.location.href = url;
  }

  @override
  Future<void> launchDeepLink(String id) async {
    html.window.location.href = id;
  }

  @override
  String getUserAgent() {
    return html.window.navigator.userAgent.toLowerCase();
  }
}
