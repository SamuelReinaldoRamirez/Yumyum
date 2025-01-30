// ignore_for_file: library_private_types_in_public_api
// ignore: library_prefixes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:yummap/firebase_options.dart';
import 'package:yummap/helper/context_helper.dart';
import 'package:yummap/page/home_page.dart';
import 'package:yummap/page/share_page.dart';
import 'package:yummap/page/splash_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/constant/keys_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:yummap/services/monitoring_service.dart';
import 'package:yummap/services/cache_manager.dart';
import 'package:yummap/page/deep_profile_page.dart';
import 'package:yummap/platform/platform.dart';
import 'package:yummap/services/stream_manager.dart';

PlatformInterface getCurrentPlatform() {
  if (!kIsWeb) {
    return MobilePlatform();
  } else {
    return WebPlatform();
  }
}

void _initializeWeb() {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initializeWeb();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  // Capture des erreurs de la plateforme
  PlatformDispatcher.instance.onError = (error, stack) {
    print("Platform error: $error");
    return true;
  };

  runZonedGuarded<Future<void>>(() async {
    try {
      await MixpanelService.initialize(mixpanelToken);
    } catch (e, stack) {
      print("Mixpanel initialization failed: $e");
    }

    runApp(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return MyApp();
          },
        ),
      ),
    );
  }, (error, stack) {
    print("Unhandled error: $error");
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
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  final StreamManager _streamManager = StreamManager();
  String mapAccount = '';

  @override
  Widget build(BuildContext context) {
    return Builder(
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

  Future<void> _initializeResources() async {
    if (!mounted) return;
    try {
      await Future.wait([
        _initDeepLinking(),
      ]);
      _setupSubscriptions();
    } catch (e) {
      print("Error initializing resources: $e");
    }
  }

  Future<void> _initDeepLinking() async {
    _appLinks = AppLinks();
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleIncomingLink(uri);
      }
      _appLinks.uriLinkStream.listen(
        _handleIncomingLink,
        onError: (e) {
          print("Error with deep linking: $e");
        },
      );
    } catch (e) {
      print("Deep linking initialization failed: $e");
    }
  }

  void _handleIncomingLink(Uri? uri) {
    if (!mounted || uri == null) return;

    try {
      print("Received URI: $uri"); // Debug print

      if (uri.scheme == 'yummap') {
        // Nettoyer et normaliser le host/path
        final path = uri.host + (uri.path.isEmpty ? '' : uri.path);
        print("Normalized path: $path"); // Debug print

        // Vérifier si c'est un deepProfile
        if (path.toLowerCase().startsWith('deepprofile')) {
          // Extraire l'ID en ignorant 'deepprofile/'
          final id = uri.pathSegments.lastWhere(
            (segment) => segment != 'deepprofile',
            orElse: () => '',
          );

          print("Extracted ID: $id"); // Debug print

          if (id.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _router.go('/deepProfile/$id');
            });
          }
        }
      }
    } catch (e) {
      print("Error processing incoming link: $e");
    }
  }

  void _setupSubscriptions() {
    // Exemple de stream à écouter, à remplacer par le stream réel
    final Stream<dynamic> exampleStream =
        Stream.periodic(Duration(seconds: 1), (count) => count);

    _streamManager.addSubscription(
        'exampleStream',
        exampleStream.listen((data) {
          // Traiter les données reçues
        }, onError: (error) {
          print('Stream error: $error');
        }));
  }

  @override
  void didUpdateWidget(MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/share/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SharePage(id: id);
      },
    ),
    // Ajoutez cette route pour le deep link
    GoRoute(
      path: '/deepProfile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DeepProfilePage(id: id);
      },
    ),
  ],
);
