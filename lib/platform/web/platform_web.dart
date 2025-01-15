// ignore: avoid_web_libraries_in_flutter
import '../platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPlatform implements PlatformInterface {
  const WebPlatform();

  @override
  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_self');
    }
  }

  @override
  Future<void> launchDeepLink(String id) async {
    final uri = Uri.parse(id);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_self');
    }
  }

  @override
  String getUserAgent() {
    return '';
  }
}

class WebPlatformStub implements PlatformInterface {
  const WebPlatformStub();

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
