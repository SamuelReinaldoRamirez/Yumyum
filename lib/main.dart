// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:yummap/filter_bar.dart';
// import 'package:yummap/global.dart';
// import 'package:yummap/map_page.dart';
// import 'package:yummap/call_endpoint_service.dart';
// import 'package:yummap/restaurant.dart';
// import 'package:yummap/keys_data.dart'; // Importez le fichier contenant le token Mixpanel
// import 'package:yummap/mixpanel_service.dart'; // Importez la classe MixpanelService
// // ignore: library_prefixes
// import 'package:yummap/search_bar.dart' as CustomSearchBar;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await MixpanelService.initialize(mixpanelToken);

//   List<Restaurant> restaurantList =
//       (await CallEndpointService().getRestaurantsFromXanos()).cast<Restaurant>();
//   await initializeGlobals();
//   runApp(MyApp(restaurantList: restaurantList));
// }

// class MyApp extends StatefulWidget {
//   final List<Restaurant> restaurantList;

//   MyApp({Key? key, required this.restaurantList}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   late Mixpanel _mixpanel;

//   @override
//   void initState() {
//     super.initState();
//     _mixpanel = MixpanelService.instance;
//     WidgetsBinding.instance.addObserver(this);
//     // Envoyer un événement de "Session Start" lorsque l'application est démarrée
//     _mixpanel.track('Session Start');
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       // Envoyer un événement de "Session End" lorsque l'application est en pause
//       _mixpanel.track('Session End');
//     } else if (state == AppLifecycleState.resumed) {
//       // Mise à jour des super propriétés avec la dernière activité de l'utilisateur
//       _mixpanel.registerSuperProperties(
//           {'last_activity': DateTime.now().toString()});
//       // Envoyer un événement de "Session Start" lorsque l'application est reprise
//       _mixpanel.track('Session Start');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           //backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//       ),
//       home: Scaffold(
//         body: SingleChildScrollView(
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Column(
//               children: [

// ValueListenableBuilder<bool>(
//       valueListenable: isFilterVisibleForMain,
//       builder: (context, isFilterVisibleForMainValue, child) {
//         return
//                 SizedBox(
//                   height: isFilterVisibleForMainValue
//                       ? MediaQuery.of(context).size.height * 0.155
//                       : MediaQuery.of(context).size.height * 0.1,
//                   child: CustomSearchBar.SearchBar(
//                     onSearchChanged: (value) {},
//                     restaurantList: widget.restaurantList,
//                     selectedTagIdsNotifier: selectedTagIdsNotifier,
//                     selectedWorkspacesNotifier: selectedWorkspacesNotifier,
//                   ),
//                 );
//       }
// ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height *
//                       0.84, // 90% de la hauteur de l'écran
//                   child: MapPage(restaurantList: widget.restaurantList),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/global.dart';
import 'package:yummap/map_page.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/keys_data.dart'; // Importez le fichier contenant le token Mixpanel
import 'package:yummap/mixpanel_service.dart'; // Importez la classe MixpanelService
// ignore: library_prefixes
import 'package:yummap/search_bar.dart' as CustomSearchBar;
import 'package:easy_localization/easy_localization.dart'; // Importer easy_localization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized(); // Initialiser easy_localization

  await MixpanelService.initialize(mixpanelToken);

  List<Restaurant> restaurantList =
      (await CallEndpointService().getRestaurantsFromXanos()).cast<Restaurant>();
  await initializeGlobals();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr')], // Définir les langues supportées
      path: 'assets/i18n', // Dossier contenant les fichiers de traduction
      fallbackLocale: Locale('en'), // Langue de secours en cas de problème
      child: MyApp(restaurantList: restaurantList),
    ),
  );
}

class MyApp extends StatefulWidget {
  final List<Restaurant> restaurantList;

  MyApp({Key? key, required this.restaurantList}) : super(key: key);

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
      _mixpanel.track('Session End');
    } else if (state == AppLifecycleState.resumed) {
      _mixpanel.registerSuperProperties(
          {'last_activity': DateTime.now().toString()});
      _mixpanel.track('Session Start');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Current locale: ${context.locale}');  // Affiche la locale du device
    return MaterialApp(
      title: "Yummap".tr(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      localizationsDelegates: context.localizationDelegates, // Delegates de localisations
      supportedLocales: context.supportedLocales, // Locales supportées
      locale: context.locale, // Locale active
      home: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isFilterVisibleForMain,
                  builder: (context, isFilterVisibleForMainValue, child) {
                    return SizedBox(
                      height: isFilterVisibleForMainValue
                          ? MediaQuery.of(context).size.height * 0.155
                          : MediaQuery.of(context).size.height * 0.1,
                      child: CustomSearchBar.SearchBar(
                        onSearchChanged: (value) {},
                        restaurantList: widget.restaurantList,
                        selectedTagIdsNotifier: selectedTagIdsNotifier,
                        selectedWorkspacesNotifier: selectedWorkspacesNotifier,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.84,
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
