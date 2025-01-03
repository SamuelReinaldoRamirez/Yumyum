// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yummap/page/map_page.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/constant/keys_data.dart';
import 'package:yummap/service/mixpanel_service.dart';
// ignore: library_prefixes
import 'package:yummap/page/search_bar.dart' as CustomSearchBar;
import 'package:yummap/widget/filter_bar.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Initializing MixpanelService...');
    await MixpanelService.initialize(mixpanelToken);
    print('MixpanelService initialized.');
  } catch (e) {
    print('Error initializing MixpanelService: $e');
  }

  print('Fetching restaurants from Xano...');
  List<Restaurant> restaurantList =
      (await CallEndpointService().getRestaurantsFromXanos())
          .cast<Restaurant>();
  print('Fetched ${restaurantList.length} restaurants.');
  runApp(MyApp(restaurantList: restaurantList));
}

class MyApp extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MyApp({Key? key, required this.restaurantList}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? currentAccount;
  late AppLinks _appLinks;
  late Mixpanel _mixpanel;
  String? mapAccount;

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
    print('Building app with mapAccount: $mapAccount');
    return MaterialApp(
      title: 'Yummap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: mapAccount != null
          ? Scaffold(
              appBar: AppBar(
                title: Text('Hello World'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      mapAccount = null;
                    });
                  },
                ),
              ),
              body: Center(
                child: Text(
                  'Hello World ${mapAccount ?? ''}',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            )
          : HomePage(restaurantList: widget.restaurantList),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Restaurant> restaurantList;

  const HomePage({
    Key? key,
    required this.restaurantList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
                child: CustomSearchBar.SearchBar(
                  onSearchChanged: (value) {},
                  restaurantList: restaurantList,
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
                child: FilterBar(
                  selectedTagIdsNotifier: ValueNotifier<List<int>>([]),
                  selectedWorkspacesNotifier: ValueNotifier<List<int>>([]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.84,
                child: MapPage(restaurantList: restaurantList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
