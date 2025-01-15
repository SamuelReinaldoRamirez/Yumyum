// ignore: avoid_web_libraries_in_flutter
import 'platform_interface.dart';

class WebPlatform implements PlatformInterface {
  const WebPlatform();

  @override
  Future<void> launchURL(String url) async {
    throw UnsupportedError('Web platform not supported in non-web environment');
  }

  @override
  Future<void> launchDeepLink(String id) async {
    throw UnsupportedError('Web platform not supported in non-web environment');
  }

  @override
  String getUserAgent() {
    return '';
  }
}
