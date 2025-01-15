import 'package:flutter/foundation.dart';
import 'platform_interface.dart';
import 'platform_mobile.dart';
import 'platform_web.dart' if (dart.library.html) 'platform_web.web.dart';

export 'platform_interface.dart';
export 'platform_mobile.dart';
export 'platform_web.dart' if (dart.library.html) 'platform_web.web.dart';

/// Returns the current platform implementation based on the runtime environment.
PlatformInterface getPlatform() {
  if (kIsWeb) {
    return const WebPlatform();
  }
  return const MobilePlatform();
}
