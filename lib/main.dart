// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:yummap/caching.dart';
// import 'package:yummap/global.dart';
// import 'package:yummap/map_page.dart';
// import 'package:yummap/call_endpoint_service.dart';
// import 'package:yummap/restaurant.dart';
// import 'package:yummap/keys_data.dart'; // Importez le fichier contenant le token Mixpanel
// import 'package:yummap/mixpanel_service.dart'; // Importez la classe MixpanelService
// // ignore: library_prefixes
// import 'package:yummap/search_bar.dart' as CustomSearchBar;
// import 'package:easy_localization/easy_localization.dart';
// import 'package:yummap/tag.dart'; // Importer easy_localization

// //une fois qu'on a bien géré les filtres, on gere les cuisines pareil.
// // 4) cache pour toutes les strings
// // 5) mapbox translate
// // 8) stocker les locales sur aws et les charger à la demande? plutot que de toutes les avoir dna sle telephone de tout le monde inutilement?
// // idk) mettre toutes les sizes en taille relative de l'ecran comme dans le main
// // idk) deployer yummap sur firebase ou git en demandant à gpt
// // idk) gerer la position et l'orientation de l'utilisateur
// // idk) faire des soustitres pour toutes les videos et les traduire
// // idk) bouton boussole pour remettre le nord au nord
// // photos des hotels dans les commentaires des hotels
// //il faut traduire les reviews meme si on a un systeme en francais car les reviews sont souvent ecrites en anglais
// //en fait on va plutot mettre un bouton "traduire le commentaire (la review), si l'envie nous en dit"
// // arreter avec les pseudocaches et créer le fichier au chargement de l'application

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized(); // Initialiser easy_localization
//   await MixpanelService.initialize(mixpanelToken);
//   await initializeGlobals();

//   List<Restaurant> restaurantList = await CallEndpointService().getRestaurantsFromXanos();
//       // (await CallEndpointService().getRestaurantsFromXanos()).cast<Restaurant>();
//   List<Tag> tagList = await CallEndpointService().getTagsFromXanos();

//   runApp(
//     EasyLocalization(
//       supportedLocales: const [
//         Locale('af'),
//         Locale('sq'),
//         Locale('am'),
//         Locale('ar'),
//         Locale('hy'),
//         Locale('az'),
//         Locale('eu'),
//         Locale('be'),
//         Locale('bn'),
//         Locale('bs'),
//         Locale('bg'),
//         Locale('ca'),
//         Locale('ceb'),
//         Locale('ny'),
//         Locale('zh'),
//         // Locale('zh', 'CN'), // Chinese Simplified
//         // Locale('zh', 'TW'), // Chinese Traditional
//         Locale('co'),
//         Locale('hr'),
//         Locale('cs'),
//         Locale('da'),
//         Locale('nl'),
//         Locale('en'),
//         // Locale('eo'),
//         Locale('et'),
//         Locale('tl'),
//         Locale('fi'),
//         Locale('fr'),
//         Locale('fy'),
//         Locale('gl'),
//         Locale('ka'),
//         Locale('de'),
//         Locale('el'),
//         Locale('gu'),
//         Locale('ht'),
//         Locale('ha'),
//         Locale('haw'),
//         Locale('he'),
//         Locale('hi'),
//         Locale('hmn'),
//         Locale('hu'),
//         Locale('is'),
//         Locale('ig'),
//         Locale('id'),
//         Locale('ga'),
//         Locale('it'),
//         Locale('ja'),
//         Locale('jw'),
//         Locale('kn'),
//         Locale('kk'),
//         Locale('km'),
//         Locale('ko'),
//         Locale('ku'),
//         Locale('ky'),
//         Locale('lo'),
//         Locale('la'),
//         Locale('lv'),
//         Locale('lt'),
//         Locale('lb'),
//         Locale('mk'),
//         Locale('mg'),
//         Locale('ms'),
//         Locale('ml'),
//         Locale('mt'),
//         Locale('mi'),
//         Locale('mr'),
//         Locale('mn'),
//         Locale('my'),
//         Locale('ne'),
//         Locale('no'),
//         Locale('ps'),
//         Locale('fa'),
//         Locale('pl'),
//         Locale('pt'),
//         Locale('pa'),
//         Locale('ro'),
//         Locale('ru'),
//         Locale('sm'),
//         Locale('gd'),
//         Locale('sr'),
//         Locale('st'),
//         Locale('sn'),
//         Locale('sd'),
//         Locale('si'),
//         Locale('sk'),
//         Locale('sl'),
//         Locale('so'),
//         Locale('es'),
//         Locale('su'),
//         Locale('sw'),
//         Locale('sv'),
//         Locale('tg'),
//         Locale('ta'),
//         Locale('te'),
//         Locale('th'),
//         Locale('tr'),
//         Locale('uk'),
//         Locale('ur'),
//         Locale('uz'),
//         Locale('ug'),
//         Locale('vi'),
//         Locale('cy'),
//         Locale('xh'),
//         Locale('yi'),
//         Locale('yo'),
//         Locale('zu')
//         ], // Définir les langues supportées
//       path: 'assets/i18n', // Dossier contenant les fichiers de traduction
//       fallbackLocale: const Locale('en'), // Langue de secours en cas de problème
//       child: MyApp(restaurantList: restaurantList, tagList: tagList),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   final List<Restaurant> restaurantList;
//   final List<Tag> tagList;

//   MyApp({Key? key, required this.restaurantList, required this.tagList}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   late Mixpanel _mixpanel;
//   Logger logger = Logger();
  

//   @override
// void initState() {
//   super.initState();
//   _initAsync(); // Appelle une méthode séparée pour l'async
//   _mixpanel = MixpanelService.instance;
//   WidgetsBinding.instance.addObserver(this);
//   _mixpanel.track('Session Start');
// }


// Future<void> _initAsync() async {
//   try {
//     // Créer ou mettre à jour le fichier filtres.json avec les données des tags
//     await createOrUpdateJsonFile(widget.tagList);
//     filtersFinishedLoading.value = true;
//     // await createOrUpdateLocalizedJsonFile(tags, context);
//     print("Fichier filtres_fr.json mis à jour !");
//   } catch (e) {
//     print("Erreur lors de la mise à jour de filtres_fr.json : $e");
//   }

//   try {
//     // Créer ou mettre à jour le fichier filtres.json avec les données des tags
//     if(context.locale.languageCode != "fr"){
//       //pour les filtres
//       await createOrUpdateGLOBALLocalizedJsonFileBatched(widget.tagList, context, 30);
//       //pour les infos des restos
//       await createOrUpdateGLOBALLocalizedRestoInfosJsonFileBatched(widget.restaurantList, context, 16);
//       print("Fichier filtres.json mis à jour !");
//     }
//   } catch (e) {
//     print("Erreur lors de la mise à jour de filtres.json : $e");
//   }
  
// }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _mixpanel.track('Session End');
//     } else if (state == AppLifecycleState.resumed) {
//       _mixpanel.registerSuperProperties(
//           {'last_activity': DateTime.now().toString()});
//       _mixpanel.track('Session Start');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Current locale: ${context.locale}');  // Affiche la locale du device
//     return MaterialApp(
//       title: "Yummap".tr(),
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           elevation: 0,
//         ),
//       ),
//       localizationsDelegates: context.localizationDelegates, // Delegates de localisations
//       supportedLocales: context.supportedLocales, // Locales supportées
//       locale: context.locale, // Locale active
//       home: Scaffold(
//         body: SingleChildScrollView(
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Column(
//               children: [
//                 ValueListenableBuilder<bool>(
//                   valueListenable: isFilterVisibleForMain,
//                   builder: (context, isFilterVisibleForMainValue, child) {
//                     return SizedBox(
//                       height: isFilterVisibleForMainValue
//                           ? MediaQuery.of(context).size.height * 0.16
//                           : MediaQuery.of(context).size.height * 0.1,
//                       child: CustomSearchBar.SearchBar(
//                         onSearchChanged: (value) {},
//                         restaurantList: widget.restaurantList,
//                         selectedTagIdsNotifier: selectedTagIdsNotifier,
//                         selectedWorkspacesNotifier: selectedWorkspacesNotifier,
//                         tagList : widget.tagList
//                       ),
//                     );
//                   },
//                 ),
//                 ValueListenableBuilder<bool>(
//                   valueListenable: isFilterVisibleForMain,
//                   builder: (context, isFilterVisibleForMainValue, child) {
//                     return 
//                 SizedBox(
//                   height: isFilterVisibleForMainValue
//                           ? MediaQuery.of(context).size.height * 0.84
//                           : MediaQuery.of(context).size.height * 0.9,
//                   child: MapPage(restaurantList: widget.restaurantList),
//                 );
//                   }
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // onGenerateRoute: (settings) {
//       //   if (settings.name != null && settings.name!.startsWith('/hotel/')) {
//       //     // Extraction de l'ID de l'hôtel depuis la route
//       //     final id = settings.name!.replaceFirst('/hotel/', '');
//       //     return MaterialPageRoute(
//       //       builder: (context) {
//       //         return 
//       //         List<Restaurant> restaurants = await CallEndpointService().getRestaurantsByTagsAndWorkspaces([], [widget.workspace.id]);
//       //                   if (restaurants.isNotEmpty) {
//       //                     // Afficher les restaurants sur la carte
//       //                     MarkerManager.createFull(
//       //                         MarkerManager.context, restaurants);
//       //                     //SI l'hotel recommande TOUS les restos de notre bdd, la croix sera entourée mais le veut-on?!
//       //                     //quand on clique sur voir les recommandations de l'hotel, ne faudrait-il pas que ca le coche dans les workspaces filtres si on est déjà abonné?
//       //                     filterIsOn.value = true;
//       //                   } else {
//       //                     ScaffoldMessenger.of(MarkerManager.context)
//       //                         .showSnackBar(
//       //                       SnackBar(
//       //                         content: Text(
//       //                             "no result found for workspace".tr()),
//       //                       ),
//       //                     );
//       //                   }
//       //                   Navigator.pop(context, widget.workspace);
//       //       },
//       //     );
//       //   }
//       //   return null;
//       // },
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:yummap/depp_link_manager.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //pour le debug :
  // await FlutterBranchSdk.init().then((result) {
  //   // Gérez le résultat ici
  //   FlutterBranchSdk.validateSDKIntegration();
  // }).catchError((error) {
  //   // Gérez les erreurs ici
  //   print('Erreur lors de la validation de l\'intégration: $error');
  // });

  //pour la prod
  await FlutterBranchSdk.init();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trois Routes App',
      // Définir la page 1 comme route par défaut
      initialRoute: '/',
      routes: {
        '/': (context) => Page1(),  // Page 1 par défaut
        '/page2': (context) => Page2(idHotel: 0),  // Page 2
        '/page3': (context) => Page3(),  // Page 3
      },
    );
  }
}

// Page 1 transformée en StatefulWidget
class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  bool sdkInitialized = true;
    // On considère que le SDK est initialisé après le main()
    BranchManager flutterBranchInstance = BranchManager(); // Crée une instance de FlutterBranchInstance

  @override
  void initState(){
    super.initState();
    flutterBranchInstance.listenDynamicLinks2(context);
    flutterBranchInstance.initDeepLinkData2("default", 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/page2');
              },
              child: Text('Aller à la Page 2'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/page3');
              },
              child: Text('Aller à la Page 3'),
            ),
            SizedBox(height: 20),
            Text(sdkInitialized
                ? 'SDK Branch initialisé'
                : 'Initialisation du SDK Branch...'),
            ElevatedButton(
              onPressed: () {
                flutterBranchInstance.generateLink2(context, "page1", 0);
              },
              child: Text("generer le lien"),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 2
class Page2 extends StatelessWidget {
  BranchManager flutterBranchInstance = BranchManager();
  int idHotel = 0;

  Page2({required this.idHotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue sur la Page 2, l\'id de l\'hotel est : $idHotel'),
            ElevatedButton(
              onPressed: () {
                flutterBranchInstance.generateLink2(context, "page2", 22);
              },
              child: Text("generer le lien"),
            ),
          ]
        ),
      ),
      
    );
  }
}

// Page 3
class Page3 extends StatelessWidget {
  BranchManager flutterBranchInstance = BranchManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue sur la Page 3'),
            ElevatedButton(
              onPressed: () {
                flutterBranchInstance.generateLink2(context, "page3", 9);
              },
              child: Text("generer le lien"),
            ),
          ]
        ),
      ),
    );
  }
}