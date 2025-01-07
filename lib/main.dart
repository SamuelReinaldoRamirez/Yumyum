// ignore_for_file: library_private_types_in_public_api
// ignore: library_prefixes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yummap/page/home_page.dart';
import 'package:yummap/page/splash_screen.dart';
import 'package:yummap/helper/context_helper.dart'; // Importer le ContextHelper
import 'package:app_links/app_links.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/constant/keys_data.dart';
// Importer StreamManager
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // Fichier généré
import 'package:flutter/foundation.dart';

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
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  String mapAccount = '';
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinking();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    try {
      print('Initializing MixpanelService...');
      print('MixpanelService initialized.');
    } catch (e) {
      print('Error initializing MixpanelService: $e');
    }
  }

  Future<void> _initDeepLinking() async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final uri = await _appLinks.getInitialLink();
      print('Initial link: $uri');
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }

    // Listen for incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        print('Incoming link: $uri');
        _handleIncomingLink(uri);
      },
      onError: (e) {
        print('Error handling incoming links: $e');
      },
    );

    // Check for any intent that launched the app
    final uri = Uri.parse(Uri.base.toString());
    if (uri.scheme == 'yummap') {
      print('App launched with URI: $uri');
      _handleIncomingLink(uri);
    }
  }

  void _handleIncomingLink(Uri? uri) {
    if (uri == null) return;

    print('Handling incoming link: $uri');
    print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    final pathSegments = uri.pathSegments;
    print('Path segments: $pathSegments');

    if (uri.scheme == 'yummap' && uri.host == 'map') {
      final account = pathSegments.isNotEmpty ? pathSegments[0] : '';
      print('Navigation to map for account: $account');
      setState(() {
        mapAccount = account;
      });
    } else if (pathSegments.isNotEmpty && pathSegments[0] == 'map') {
      final account = pathSegments.length > 1 ? pathSegments[1] : '';
      print('Navigation to map for account: $account');
      setState(() {
        mapAccount = account;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel(); // Annuler l'écoute des deep links
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // L'app passe en arrière-plan
        _cleanupResources();
        break;
      case AppLifecycleState.resumed:
        // L'app revient en premier plan
        _reinitializeResources();
        break;
      default:
        break;
    }
  }

  void _cleanupResources() {
    imageCache.clear();
    imageCache.clearLiveImages();
    // Autres nettoyages nécessaires
  }

  void _reinitializeResources() {
    // Réinitialiser les ressources nécessaires
    // Recharger les données si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    // Définir le contexte global
    ContextHelper.setContext(context);
    return MaterialApp(
      title: 'Yummap',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
