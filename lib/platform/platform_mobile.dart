import 'package:url_launcher/url_launcher.dart';
import 'platform_interface.dart';

class MobilePlatform implements PlatformInterface {
  const MobilePlatform();
  
  @override
  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Future<void> launchDeepLink(String id) async {
    final uri = Uri.parse(id);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  String getUserAgent() {
    return ''; // Mobile doesn't need user agent detection
  }
}
