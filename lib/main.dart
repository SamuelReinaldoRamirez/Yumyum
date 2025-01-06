// ignore_for_file: library_private_types_in_public_api
// ignore: library_prefixes

import 'package:flutter/material.dart';
import 'package:yummap/page/home_page.dart';
import 'package:yummap/page/splash_screen.dart';
import 'package:yummap/helper/context_helper.dart'; // Importer le ContextHelper
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:yummap/service/mixpanel_service.dart';
import 'package:yummap/constant/keys_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Initializing MixpanelService...');
    await MixpanelService.initialize(mixpanelToken);
    print('MixpanelService initialized.');
  } catch (e) {
    print('Error initializing MixpanelService: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Mixpanel _mixpanel;
  late AppLinks _appLinks;
  String mapAccount = '';

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    try {
      print('Initializing MixpanelService...');
      _mixpanel = await MixpanelService.instance;
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
    _appLinks.uriLinkStream.listen(
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
