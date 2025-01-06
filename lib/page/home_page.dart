import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummap/page/explore_page.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/restaurant.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Restaurant> restaurantList = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final restaurants = await CallEndpointService().getRestaurantsFromXanos();
      setState(() {
        restaurantList = restaurants;
        print("---------------------");
        print("---------------------");
        print(restaurants);
      });
    } catch (e) {
      // Gérer l'erreur ici (afficher un message, etc.)
      print('Erreur lors de la récupération des restaurants: $e');
    }
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
