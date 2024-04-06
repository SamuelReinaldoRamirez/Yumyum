import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/reviews_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/horaires_restaurant.dart'; // Importez le fichier contenant le widget horaire

class RestaurantDetailsWidget extends StatefulWidget {
  const RestaurantDetailsWidget({Key? key, required this.restaurant})
      : super(key: key);
  final Restaurant restaurant;

  @override
  _RestaurantDetailsWidgetState createState() =>
      _RestaurantDetailsWidgetState(restaurant);
}

class FractionalClipper extends CustomClipper<Rect> {
  final double fraction;

  FractionalClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(FractionalClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

class _RestaurantDetailsWidgetState extends State<RestaurantDetailsWidget> {
  Restaurant restaurant;
  String _photoReference = '';
  bool _isLoading = false;
  String _noteMoyenne = "";
  int _userRatingsTotal = 0;
  String? _siteInternet;
  String? _instagram;
  String? _menu;
  _RestaurantDetailsWidgetState(this.restaurant);

  double convertFraction(fraction) {
    fraction = (fraction * 10).round();
    if (fraction < 1)
      return 0.15;
    else if (fraction < 2)
      return 0.32;
    else if (fraction < 3)
      return 0.35;
    else if (fraction < 4)
      return 0.40;
    else if (fraction < 5)
      return 0.45;
    else if (fraction == 5)
      return 0.5;
    else if (fraction >= 9)
      return 0.80;
    else if (fraction >= 8)
      return 0.65;
    else if (fraction >= 7)
      return 0.60;
    else if (fraction >= 6)
      return 0.55;
    else if (fraction < 6) return 0.52;
    return 0.5;
  }

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  Future<String> fetchPlaceId(Restaurant restaurante) async {
    String placeId = "";
    String name = restaurante.name.trim();
    String latitude = restaurante.latitude.toString();
    String longitude = restaurante.longitude.toString();
    try {
      http.Response response = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$name&location=$latitude,$longitude&radius=500&type=restaurant&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        placeId = data['results'][0]['reference'];
        restaurant.setPlaceId(placeId);
      } else {
        print('Erreur lors de la requête: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la requête: $error');
    }
    return placeId;
  }

  Future<void> _fetchRestaurantDetails() async {
    if (this.restaurant.getPlaceId().isEmpty) {
      String placeId = await fetchPlaceId(restaurant);
      restaurant.setPlaceId(placeId);
    }

    String apiKey = 'AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U';
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${restaurant.getPlaceId()}&key=$apiKey';

    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> photosData = data['result']['photos'];

        _noteMoyenne = data['result']['rating'] != null
            ? data['result']['rating'].toString()
            : '0';
        _userRatingsTotal = data['result']['user_ratings_total'];

        if (photosData.isNotEmpty) {
          _photoReference = photosData[0]['photo_reference'];
        }

        // Récupération du site web du restaurant
        if (data['result']['website'] != null) {
          _siteInternet = data['result']['website'];
        }

        // Récupération du compte Instagram du restaurant
        if (data['result']['instagram'] != null) {
          _instagram = data['result']['instagram'];
        }

        if (data['result']['menu'] != null) {
          _menu = data['result']['menu'];
        }
      } else {
        print('Erreur lors de la requête: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la requête: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  static void _navigateToReviewDetails(
      BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReviewDetailsWidget(restaurant: restaurant)),
    );
  }

  List<Widget> buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    double fraction = rating - fullStars;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber));
    }

    if (fraction > 0) {
      stars.add(Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRect(
              clipper: FractionalClipper(convertFraction(fraction)),
              child: Icon(Icons.star, size: 25, color: Colors.amber),
            ),
            Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.3))
          ],
        ),
      ));
    }

    for (int i = stars.length; i < 5; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber.withOpacity(0.3)));
    }

    return stars;
  }

  // Méthode pour ouvrir un URL dans le navigateur externe
  Future<void> _launchUrl(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.network(
                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$_photoReference&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: EdgeInsets.only(
                              bottom: 15), // Ajout de la marge en bas
                          alignment:
                              Alignment.bottomCenter, // Alignement en bas
                          child: Text(
                            widget.restaurant.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 5),
                        Text(
                          '$_noteMoyenne ($_userRatingsTotal avis)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 20), // Ajout d'un espace
                        IconButton(
                          icon: Icon(Icons.language),
                          onPressed: () {
                            // Ouvrir le site web s'il est disponible
                            if (_siteInternet != null &&
                                Uri.parse(_siteInternet.toString())
                                    .isAbsolute) {
                              _launchUrl(_siteInternet);
                            } else {
                              // Afficher un toast si le site web n'est pas disponible
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Le site web n'est pas disponible",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.photo_camera_outlined),
                          onPressed: () {
                            // Ouvrir Instagram s'il est disponible
                            if (_instagram != null &&
                                Uri.parse(_instagram.toString()).isAbsolute) {
                              _launchUrl(_instagram);
                            } else {
                              // Afficher un toast si Instagram n'est pas disponible
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Instagram n'est pas disponible",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.local_dining), // Icône de la cuisine
                            SizedBox(width: 5),
                            Text(
                              'Cuisine française', // Exemple de type de cuisine
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.accessibility),
                            SizedBox(width: 5),
                            Text(
                              'Accessible aux personnes à mobilité réduite',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.eco),
                            SizedBox(width: 5),
                            Text(
                              'Propose des plats végétariens',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SizedBox(height: 130, child: HorairesRestaurant()),
                        SizedBox(height: 20),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.phone),
                                title: Text(
                                    '0123456789'), // Numéro de téléphone du restaurant
                                onTap: () {
                                  // Action à effectuer lors du clic sur le numéro de téléphone
                                  launch('tel://0123456789');
                                },
                              ),
                              Divider(), // Ligne de séparation
                              ListTile(
                                leading: Icon(Icons.menu_book),
                                title: Text(
                                  'Menu', // Titre du menu
                                ),
                                onTap: () {
                                  // Ouvrir le menu s'il est disponible
                                  if (_menu != null &&
                                      Uri.parse(_menu.toString()).isAbsolute) {
                                    _launchUrl(_menu);
                                  } else {
                                    // Afficher un toast si le menu n'est pas disponible
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Le menu n'est pas disponible",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text(
                                    '123 Rue du Restaurant, Ville'), // Adresse du restaurant
                                onTap: () {
                                  // Copier l'adresse dans le presse-papiers
                                  Clipboard.setData(ClipboardData(
                                      text: '123 Rue du Restaurant, Ville'));
                                  // Afficher un message indiquant que l'adresse a été copiée
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Adresse copiée dans le presse-papiers'),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(
                                height: 200, // Hauteur de la carte
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        // Coordonnées de votre localisation
                                        37.42796133580664,
                                        -122.085749655962),
                                    zoom: 14, // Niveau de zoom initial
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(
                                          'restaurant_location'), // Identifiant du marqueur
                                      position: LatLng(37.42796133580664,
                                          -122.085749655962), // Coordonnées du marqueur
                                      infoWindow: InfoWindow(
                                        // Fenêtre d'information du marqueur
                                        title: 'Restaurant',
                                        snippet: '123 Rue du Restaurant, Ville',
                                      ),
                                    ),
                                  },
                                  mapType: MapType
                                      .normal, // Type de carte (normal, satellite, terrain, etc.)
                                  myLocationEnabled:
                                      true, // Activer la localisation de l'utilisateur
                                  zoomControlsEnabled:
                                      false, // Désactiver les contrôles de zoom
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    // Fonction appelée lorsque la carte est créée
                                    // Vous pouvez ajouter du code supplémentaire ici si nécessaire
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Ajout du widget horaires restaurant
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Widget "Avis clients"
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avis clients :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Exemple d'avis client
                        ListTile(
                          title: Text(
                            'Excellent restaurant, bonne ambiance et service rapide. Je recommande vivement !',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                '- Jean Dupont',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        // Bouton pour afficher plus d'avis
                        ElevatedButton(
                          onPressed: () {
                            // Rediriger vers la page des avis détaillés
                            _navigateToReviewDetails(context, restaurant);
                          },
                          child: Text('Voir plus d\'avis'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
