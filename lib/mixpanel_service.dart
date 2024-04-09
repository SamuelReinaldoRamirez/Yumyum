import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static late Mixpanel _mixpanel;

  static Future<void> initialize(String token) async {
    _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: false);
  }

  static Mixpanel get instance => _mixpanel;
}
