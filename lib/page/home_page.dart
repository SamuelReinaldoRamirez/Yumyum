import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummap/page/explore_page.dart';
import 'package:yummap/services/cache_manager.dart';
import 'package:yummap/services/monitoring_service.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/restaurant.dart';
import 'dart:async';
import 'package:yummap/services/stream_manager.dart'; // Importer StreamManager
import 'package:yummap/services/image_optimizer.dart'; // Importer ImageOptimizer

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String RESTAURANT_STREAM_KEY = 'restaurant_updates';
  static const String cacheKey = 'restaurants'; // Ajouter la clé de cache
  List<Restaurant> restaurantList = [];
  StreamSubscription?
      _subscription; // Ajouter la variable pour stocker l'abonnement
  final imageOptimizer = ImageOptimizer(); // Instancier ImageOptimizer

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final cache = CacheManager();
      final stopwatch = Stopwatch()..start();

      // Vérifier le cache avec gestion d'erreur
      try {
        final cachedRestaurants = cache.get<List<Restaurant>>(cacheKey);
        if (cachedRestaurants != null) {
          setState(() {
            restaurantList = cachedRestaurants;
          });
          // Rafraîchissement en arrière-plan
          _refreshInBackground();
          return;
        }
      } catch (e) {
        print('Erreur de cache: $e');
      }

      // Fetch depuis l'API
      final restaurants = await CallEndpointService().getRestaurantsFromXanos();
      // Mise en cache avec métriques
      final cacheTime = stopwatch.elapsed;
      print('Temps de récupération: ${cacheTime.inMilliseconds}ms');
      cache.set(cacheKey, restaurants, ttl: Duration(minutes: 15));

      if (!mounted) return;
      setState(() => restaurantList = restaurants);
    } catch (e) {
      // Gestion des erreurs améliorée
      print('Erreur lors de la récupération des restaurants: $e');
    }
  }

  // Nouvelle méthode pour le rafraîchissement en arrière-plan
  Future<void> _refreshInBackground() async {
    try {
      final restaurants = await CallEndpointService().getRestaurantsFromXanos();
      final cache = CacheManager();
      cache.set(cacheKey, restaurants, ttl: Duration(minutes: 15));
      if (!mounted) return;
      setState(() => restaurantList = restaurants);
    } catch (e) {
      print('Erreur de rafraîchissement en arrière-plan: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Annuler l'abonnement
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors
          .backgroundColor, // Utilisation de la couleur de fond définie dans AppColors
      body: SafeArea(
        child: Center(
          // Centrer le contenu
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Illustration sans cadre
                SvgPicture.asset(
                  'assets/illustrations/Baker-pana.svg',
                  width: 300,
                ),
                SizedBox(height: 32),
                // Titre avec styles associés
                Text(
                  'Yummap',
                  style: AppTextStyles
                      .titleBlackStyle, // Utiliser le style du thème
                ),
                SizedBox(height: 16),
                // Texte descriptif avec style de l'app
                Text(
                  'Retrouvez en un instant les meilleurs endroits pour savourer vos moments gourmands avec Yummap.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles
                      .paragraphDarkStyle, // Utiliser le style du thème
                ),
                SizedBox(height: 82),
                // Bouton
                CustomNeuButton(
                  text: 'Continuer',
                  icon: Icons.arrow_forward,
                  buttonColor: AppColors.appSecondary,
                  textColor:
                      Colors.white, // Ajout de la couleur claire pour le texte
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExplorePage(restaurantList: restaurantList)),
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    MonitoringService().forceCrash();
                  },
                  child: Text('Test Crash'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
