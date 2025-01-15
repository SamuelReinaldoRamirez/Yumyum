/// This class is intended to be an interface and should not be instantiated directly.
abstract class PlatformInterface {
  const PlatformInterface();

  Future<void> launchURL(String url);
  Future<void> launchDeepLink(String id);
  String getUserAgent();
}
