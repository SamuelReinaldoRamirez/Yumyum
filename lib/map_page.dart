import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logger/logger.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/bottom_sheet_helper.dart';
import 'package:latlong2/latlong.dart' as lat2;

class MapPage extends StatefulWidget {
  final List<Restaurant> restaurantList;

  const MapPage({Key? key, required this.restaurantList}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late MapController mapController;
  List<lat2.LatLng> restaurantLocations = [];
  static final logger = Logger();

  @override
  void initState() {
    super.initState();
    MapHelper.createRestaurantLocations(
        widget.restaurantList, restaurantLocations);

    mapController = MapController();
    //_requestAppTrackingAuthorization(context);
    MarkerManager.mapPageState = this;
    MarkerManager.context = context;
    _createListMarkers(); // Appel initial pour créer les marqueurs
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    MapHelper.getCurrentLocation((Position position) {
      // Utilisez la position ici si nécessaire
    });
  }

  void _centercamera() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    mapController.move(lat2.LatLng(position.latitude, position.longitude), 12);
  }

  Future<void> _createListMarkers() async {
    MarkerManager.markersList = MapHelper.createListMarkers(
        context, widget.restaurantList, restaurantLocations, _showMarkerInfo);
    MarkerManager.allmarkers = List<Marker>.from(MarkerManager.markersList);
    setState(
        () {}); // Mettre à jour l'état pour reconstruire la carte avec les nouveaux marqueurs
  }

  @override
  Widget build(BuildContext context) {
    // logger.d(context.deviceLocale.languageCode);
    // logger.e(context.deviceLocale.languageCode);
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: lat2.LatLng(48.8566, 2.339),
              zoom: 12,
              maxZoom: 18.4,
              minZoom: 1,
              onTap: (tapPosition, point) {
                // Fermer le clavier lors du tap sur la carte
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieXVtbWFwcyIsImEiOiJjbHJ0aDEzeGQwMXVkMmxudWg5d2EybTlqIn0.hqUva2cQmp3rXHMbON8_Kw",
                subdomains: const ['a', 'b', 'c'],
              ),
              // TileLayer(
              //   urlTemplate:
              //       "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieXVtbWFwcyIsImEiOiJjbHJ0aDEzeGQwMXVkMmxudWg5d2EybTlqIn0.hqUva2cQmp3rXHMbON8_Kw",
              //   // subdomains: const ['a', 'b', 'c'],
              //   additionalOptions: {
              //     'language': context.deviceLocale.languageCode,
              //   },
              // ),

// Voici comment tu pourrais configurer Mapbox pour afficher les noms des lieux dans une langue spécifique :

//     Modifie l'URL des tuiles Mapbox pour inclure le paramètre de langue :

//     dart

//     TileLayer(
//       urlTemplate:
//           "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=TON_ACCES_TOKEN&language={language}",
//       additionalOptions: {
//         'language': context.locale.languageCode, // Récupérer la langue de l'application
//       },
//     ),

//     Change le style de la carte si nécessaire pour en choisir un qui prend en charge plusieurs langues. Les styles streets-v11, outdoors-v11, etc., de Mapbox supportent ce genre de fonctionnalités.

//     Active les étiquettes localisées dans les paramètres de Mapbox. Les étiquettes des lieux seront automatiquement traduites en fonction du paramètre de langue passé dans l'URL.

// Cela te permettra d'adapter la carte à la langue de l'utilisateur sans avoir à gérer manuellement les traductions pour les villes et les lieux importants.
// Vous avez dit :
// ca ne marche pas. j'imagine que c'est à cause du style de ma carte?
//                     "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieXVtbWFwcyIsImEiOiJjbHJ0aDEzeGQwMXVkMmxudWg5d2EybTlqIn0.hqUva2cQmp3rXHMbON8_Kw",


// voila mon code : 
// TileLayer(
//                 urlTemplate:
//                     "https://api.mapbox.com/styles/v1/yummaps/clw628gqc02ok01qzbth1aaql/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieXVtbWFwcyIsImEiOiJjbHJ0aDEzeGQwMXVkMmxudWg5d2EybTlqIn0.hqUva2cQmp3rXHMbON8_Kw",
//                 // subdomains: const ['a', 'b', 'c'],
//                 additionalOptions: {
//                   'language': context.deviceLocale.languageCode,
//                 },
//               ),


// à quoi sert subdomains d'ailleurs?
// ChatGPT a dit :
// ChatGPT

// Dans ton code, le paramètre additionalOptions ne modifiera pas directement la langue des lieux affichés sur la carte dans un style Mapbox. Le style que tu utilises est préconfiguré, et les noms des villes et lieux importants ne sont pas forcément traduits dynamiquement.

// Pour que les noms des lieux sur une carte Mapbox soient traduits, tu dois ajuster le style de carte lui-même via le compte Mapbox ou l'API, et utiliser des sources qui supportent la localisation. Voici quelques pistes pour y parvenir :

//     Mapbox Studio : Dans Mapbox Studio, tu peux configurer le style de ta carte pour qu'il prenne en charge les traductions des noms des lieux en fonction de la langue de l'utilisateur. Tu devrais rechercher l'option de "place names" (noms des lieux) et activer la localisation pour la langue souhaitée.

//     API Mapbox GL : Si tu veux utiliser une solution côté client, tu peux envoyer une requête pour modifier dynamiquement la langue. Avec Mapbox GL JS (la version JavaScript), il est possible d'utiliser l'option language dans le style de la carte. Cependant, cette fonctionnalité n'est pas directement supportée dans Flutter.

//     Subdomains : Le paramètre subdomains permet de répartir les requêtes sur plusieurs serveurs (a, b, c) pour accélérer le chargement des tuiles en évitant d'envoyer toutes les requêtes à un seul serveur. Cela est particulièrement utile pour les applications où les cartes chargent beaucoup de données rapidement.

// Si tu veux vraiment changer la langue des lieux importants sur la carte dans Flutter, la meilleure approche est de créer un nouveau style dans Mapbox Studio avec prise en charge des langues et de l'intégrer dans ton projet.



              MarkerLayer(markers: MarkerManager.markersList),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _centercamera,
              child: Icon(Icons.my_location),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(BuildContext context, Restaurant restaurant) {
    // Envoyer l'événement "OpenPin" à Mixpanel
    MixpanelService.instance.track('OpenPin', properties: {
      'resto_id': restaurant.id,
      'resto_name': restaurant.name,
    });

    mapController.move(lat2.LatLng(restaurant.latitude, restaurant.longitude),
        mapController.zoom);
    BottomSheetHelper.showBottomSheet(context, restaurant);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
