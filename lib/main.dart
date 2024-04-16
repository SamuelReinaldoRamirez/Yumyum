// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yummap/map_page.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/keys_data.dart'; // Importez le fichier contenant le token Mixpanel
import 'package:yummap/mixpanel_service.dart'; // Importez la classe MixpanelService
// ignore: library_prefixes
import 'package:yummap/search_bar.dart' as CustomSearchBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MixpanelService.initialize(mixpanelToken);

  List<Restaurant> restaurantList =
      (await CallEndpointService.getRestaurantsFromXanos()).cast<Restaurant>();
  runApp(MyApp(restaurantList: restaurantList));
}

class MyApp extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MyApp({Key? key, required this.restaurantList}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _mixpanel = MixpanelService.instance;
    WidgetsBinding.instance.addObserver(this);
    // Envoyer un événement de "Session Start" lorsque l'application est démarrée
    _mixpanel.track('Session Start');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Envoyer un événement de "Session End" lorsque l'application est en pause
      _mixpanel.track('Session End');
    } else if (state == AppLifecycleState.resumed) {
      // Mise à jour des super propriétés avec la dernière activité de l'utilisateur
      _mixpanel.registerSuperProperties(
          {'last_activity': DateTime.now().toString()});
      // Envoyer un événement de "Session Start" lorsque l'application est reprise
      _mixpanel.track('Session Start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: CustomSearchBar.SearchBar(
                    onSearchChanged: (value) {},
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.88, // 90% de la hauteur de l'écran
                  child: MapPage(restaurantList: widget.restaurantList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
