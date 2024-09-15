import 'dart:convert';
import 'dart:io';

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
import 'package:easy_localization/easy_localization.dart';
import 'package:yummap/tag.dart'; // Importer easy_localization
import 'package:path_provider/path_provider.dart'; // Pour accéder aux chemins de fichiers locaux


// traduction des filtres à faire au moment ou on detecte un changement de local et aussi et d'abord dans le main init state avec une meilleure api que simplytranslate
//une fois qu'on a bien géré les filtres, on gere les cuisines pareil.
// 4) cache pour toutes les strings
// 5) mapbox translate
// 8) stocker les locales sur aws et les charger à la demande? plutot que de toutes les avoir dna sle telephone de tout le monde inutilement?
// idk) mettre toutes les sizes en taille relative de l'ecran comme dans le main
// idk) deployer yummap sur firebase ou git en demandant à gpt
// idk) gerer la position et l'orientation de l'utilisateur
// idk) faire des soustitres pour toutes les videos et les traduire
// idk) bouton boussole pour remettre le nord au nord
// photos des hotels dans les commentaires des hotels
//il faut traduire les reviews meme si on a un systeme en francais car les reviews sont souvent ecrites en anglais
// arreter avec les pseudocaches et créer le fichier au chargement de l'application

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
  _initAsync(); // Appelle une méthode séparée pour l'async
  _mixpanel = MixpanelService.instance;
  WidgetsBinding.instance.addObserver(this);
  _mixpanel.track('Session Start');
}


Future<void> _initAsync() async {
  try {
    // Récupérer les tags de Xano
    List<Tag> tags = await CallEndpointService().getTagsFromXanos();

    // Créer ou mettre à jour le fichier filtres.json avec les données des tags
    await createOrUpdateJsonFile(tags);

    print("Fichier filtres.json mis à jour !");
  } catch (e) {
    print("Erreur lors de la mise à jour de filtres.json : $e");
  }
}

Future<void> createOrUpdateJsonFile(List<Tag> tags) async {
  try {
    // Convertir les tags en JSON
    String tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());

    // Obtenir le répertoire de documents de l'application
    Directory directory = await getApplicationDocumentsDirectory();

    // Créer le chemin pour le sous-répertoire pseudo_caches
    String cacheDirPath = '${directory.path}/pseudo_caches';
    Directory cacheDir = Directory(cacheDirPath);

    // Si le répertoire n'existe pas, le créer
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
    }

    // Chemin du fichier filtres.json dans ce sous-répertoire
    String filePath = '$cacheDirPath/filtres.json';

    // Créer et écrire dans le fichier filtres.json
    File file = File(filePath);
    await file.writeAsString(tagsJson);

    print("Fichier filtres.json créé/mis à jour dans : $filePath");
  } catch (e) {
    print("Erreur lors de la création ou mise à jour du fichier filtres.json : $e");
  }
}


// Future<void> _initAsync() async {
//   try {
//     // Récupérer les tags de Xano
//     List<Tag> tags = await CallEndpointService().getTagsFromXanos();

//     // Convertir les tags en JSON
//     String tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());

//     // Obtenir le chemin du répertoire de documents
//     Directory directory = await getApplicationDocumentsDirectory();
    
//     // Créer le répertoire si nécessaire
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     Directory cacheDir = Directory(cacheDirPath);
//     if (!(await cacheDir.exists())) {
//       await cacheDir.create(recursive: true); // Crée le répertoire
//     }

//     // Chemin complet vers le fichier filtres.json
//     String filePath = '$cacheDirPath/filtres.json';

//     // Écrire les données dans le fichier JSON
//     File file = File(filePath);
//     await file.writeAsString(tagsJson);

//     print("Fichier filtres.json mis à jour !");
//   } catch (e) {
//     print("Erreur lors de la mise à jour de filtres.json : $e");
//   }
// }

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