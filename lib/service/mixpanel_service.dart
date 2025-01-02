import 'package:flutter/foundation.dart'; // pour kReleaseMode
// import 'package:device_info_plus/device_info_plus.dart'; // Commenté pour le web
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class MixpanelService {
  static Mixpanel? _mixpanel;

  static Future<void> initialize(String token) async {
    // Initialiser le stockage sécurisé partagé
    const storage = FlutterSecureStorage();
    const bool isDebugMode = kDebugMode;

    // Récupérer l'ID aléatoire sauvegardé localement, ou en générer un nouveau
    String? distinctId = await storage.read(key: 'ydistinctId');
    if (distinctId == null) {
      const String prefix = 'YUM-'; // Préfixe pour tous les UUID
      final String uuid = const Uuid().v4(); // Générer un UUID
      distinctId = '$prefix$uuid'; // Concaténer le préfixe et l'UUID
      await storage.write(key: 'ydistinctId', value: distinctId);
      if (!isDebugMode) {
        MixpanelService.instance.track('New User');
      }
    }

    // Initialiser Mixpanel avec l'ID distinct
    print('Initializing Mixpanel with distinct ID: $distinctId');
    _mixpanel = await Mixpanel.init(
      token,
      trackAutomaticEvents: false,
    );
    print('Mixpanel initialized successfully.');

    _mixpanel!.identify(distinctId);

  }

  static Mixpanel get instance {
    if (_mixpanel == null) {
      throw Exception('Mixpanel not initialized.');
    }
    return _mixpanel!;
  }
}
