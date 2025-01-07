import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  final _crashlytics = FirebaseCrashlytics.instance;

  Future<void> logError(dynamic error, StackTrace stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }

  Future<void> logMessage(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  void forceCrash() {
    throw Exception('Test Crash');
  }
}
