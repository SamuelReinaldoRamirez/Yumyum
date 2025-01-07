// ignore_for_file: library_private_types_in_public_api
// ignore: library_prefixes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yummap/helper/context_helper.dart';
import 'package:yummap/page/home_page.dart';
import 'package:yummap/page/splash_screen.dart';
// Importer le ContextHelper
import 'package:app_links/app_links.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/constant/keys_data.dart';
// Importer StreamManager
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // Fichier généré
import 'package:flutter/foundation.dart';
import 'package:yummap/services/monitoring_service.dart';
import 'package:yummap/services/cache_manager.dart';
import 'package:yummap/services/stream_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase avec les options générées
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuration de Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Capture des erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // Capture des erreurs de la plateforme
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Exécution de l'application dans une zone protégée
  runZonedGuarded<Future<void>>(() async {
    try {
      await MixpanelService.initialize(mixpanelToken);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

final mapAccountProvider =
    StateNotifierProvider<MapAccountNotifier, String>((ref) {
  return MapAccountNotifier();
});

class MapAccountNotifier extends StateNotifier<String> {
  MapAccountNotifier() : super('');

  void updateMapAccount(String newAccount) => state = newAccount;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  final StreamManager _streamManager = StreamManager();
  String mapAccount = '';

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Builder(
        builder: (context) {
          ContextHelper.setContext(context);
          return MaterialApp.router(
            title: 'Yummap',
            routerConfig: _router,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeResources();
    });
  }

  @override
  void dispose() {
    _streamManager.cancelAll();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cleanupResources();
        break;
      default:
        break;
    }
  }

  void _cleanupResources() {
    _streamManager.cancelAll();
    CacheManager().clear();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _initializeResources() async {
    if (!ContextHelper.hasContext) return;
    await _initDeepLinking();
    await _initMixpanel();
    _setupSubscriptions();
  }

  Future<void> _initMixpanel() async {
    try {
      await MonitoringService().logMessage('MixpanelService initialized');
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Mixpanel initialization failed');
    }
  }

  Future<void> _initDeepLinking() async {
    _appLinks = AppLinks();
    try {
      final uri = await _appLinks.getInitialLink();
      await MonitoringService().logMessage('Initial link processed: $uri');
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Deep linking initialization failed');
    }
  }

  void _handleIncomingLink(Uri? uri) {
    if (uri == null) return;

    final String newAccount = _extractAccountFromUri(uri);
    if (newAccount != mapAccount) {
      setState(() {
        mapAccount = newAccount;
      });
    }
  }

  String _extractAccountFromUri(Uri uri) {
    if (uri.scheme == 'yummap' && uri.host == 'map') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    } else if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'map') {
      return uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    }
    return '';
  }

  void _setupSubscriptions() {}
}

final _router = GoRouter(
  initialLocation: '/', // Ajout de l'emplacement initial
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/map/:id',
      builder: (context, state) => MapScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);

class MapScreen extends ConsumerStatefulWidget {
  final String id;
  const MapScreen({required this.id, Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(mapAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}

// Exemple de gestion d'erreurs
Future<void> fetchData() async {
  try {
    // Votre logique de récupération de données
  } catch (e) {
    // Gérer l'erreur ici
    print('Erreur: $e');
  }
}
