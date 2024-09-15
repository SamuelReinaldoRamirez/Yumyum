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


// 0) OK generer tous les fichiers de translate qui sont mentionnés dans main
// 1b) OK faire une branche en reroll le dernier commit pour voir à quel point les traductions dynamiques font lagger
// 2) OK en bar de recherche #lang pour switcher la langue?
// 2b) OK centrer le bouton comptes suivis et le bouton filtres etc
// 3) OK anglais par defaut quand le fichier de traduction est absent
// 7) OK à la place du shake, faire ## dans la recherche ou ### pour activer/desactiver le shake
// idk) OK laisser plus de place pour voir tout le placeholder de la searchbar
// idk) OK onsearchchaged mettre la croix en orange
// 4) cache pour toutes les strings
// 5) mapbox translate
// 8) stocker les locales sur aws et les charger à la demande? plutot que de toutes les avoir dna sle telephone de tout le monde inutilement?
// idk) mettre toutes les sizes en taille relative de l'ecran comme dans le main
// idk) deployer yummap sur firebase ou git en demandant à gpt
// idk) gerer la position et l'orientation de l'utilisateur
// idk) faire des soustitres pour toutes les videos et les traduire


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized(); // Initialiser easy_localization

  await MixpanelService.initialize(mixpanelToken);

  List<Restaurant> restaurantList =
      (await CallEndpointService().getRestaurantsFromXanos()).cast<Restaurant>();
  await initializeGlobals();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('af'),
        Locale('sq'),
        Locale('am'),
        Locale('ar'),
        Locale('hy'),
        Locale('az'),
        Locale('eu'),
        Locale('be'),
        Locale('bn'),
        Locale('bs'),
        Locale('bg'),
        Locale('ca'),
        Locale('ceb'),
        Locale('ny'),
        Locale('zh'),
        // Locale('zh', 'CN'), // Chinese Simplified
        // Locale('zh', 'TW'), // Chinese Traditional
        Locale('co'),
        Locale('hr'),
        Locale('cs'),
        Locale('da'),
        Locale('nl'),
        Locale('en'),
        Locale('eo'),
        Locale('et'),
        Locale('tl'),
        Locale('fi'),
        Locale('fr'),
        Locale('fy'),
        Locale('gl'),
        Locale('ka'),
        Locale('de'),
        Locale('el'),
        Locale('gu'),
        Locale('ht'),
        Locale('ha'),
        Locale('haw'),
        Locale('he'),
        Locale('hi'),
        Locale('hmn'),
        Locale('hu'),
        Locale('is'),
        Locale('ig'),
        Locale('id'),
        Locale('ga'),
        Locale('it'),
        Locale('ja'),
        Locale('jw'),
        Locale('kn'),
        Locale('kk'),
        Locale('km'),
        Locale('ko'),
        Locale('ku'),
        Locale('ky'),
        Locale('lo'),
        Locale('la'),
        Locale('lv'),
        Locale('lt'),
        Locale('lb'),
        Locale('mk'),
        Locale('mg'),
        Locale('ms'),
        Locale('ml'),
        Locale('mt'),
        Locale('mi'),
        Locale('mr'),
        Locale('mn'),
        Locale('my'),
        Locale('ne'),
        Locale('no'),
        Locale('ps'),
        Locale('fa'),
        Locale('pl'),
        Locale('pt'),
        Locale('pa'),
        Locale('ro'),
        Locale('ru'),
        Locale('sm'),
        Locale('gd'),
        Locale('sr'),
        Locale('st'),
        Locale('sn'),
        Locale('sd'),
        Locale('si'),
        Locale('sk'),
        Locale('sl'),
        Locale('so'),
        Locale('es'),
        Locale('su'),
        Locale('sw'),
        Locale('sv'),
        Locale('tg'),
        Locale('ta'),
        Locale('te'),
        Locale('th'),
        Locale('tr'),
        Locale('uk'),
        Locale('ur'),
        Locale('uz'),
        Locale('ug'),
        Locale('vi'),
        Locale('cy'),
        Locale('xh'),
        Locale('yi'),
        Locale('yo'),
        Locale('zu')
        ], // Définir les langues supportées
      path: 'assets/i18n', // Dossier contenant les fichiers de traduction
      fallbackLocale: const Locale('en'), // Langue de secours en cas de problème
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
                          ? MediaQuery.of(context).size.height * 0.16
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
                ValueListenableBuilder<bool>(
                  valueListenable: isFilterVisibleForMain,
                  builder: (context, isFilterVisibleForMainValue, child) {
                    return 
                SizedBox(
                  height: isFilterVisibleForMainValue
                          ? MediaQuery.of(context).size.height * 0.84
                          : MediaQuery.of(context).size.height * 0.9,
                  child: MapPage(restaurantList: widget.restaurantList),
                );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}