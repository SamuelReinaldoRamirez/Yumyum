// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/theme.dart';
import 'restaurant.dart';
import 'reviews_details.dart';
import 'horaires_restaurant.dart';

class RestaurantDetailsWidget extends StatefulWidget {
  const RestaurantDetailsWidget({Key? key, required this.restaurant})
      : super(key: key);

  final Restaurant restaurant;

  @override
  _RestaurantDetailsWidgetState createState() =>
      _RestaurantDetailsWidgetState();
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
  String _photoReference = '';
  bool _isLoading = false;
  String _noteMoyenne = '';
  int _userRatingsTotal = 0;
  String? _siteInternet;
  int _price = 0;
  String? _cuisine;
  List<List<String>>? _schedule;
  List<ReviewRestau> _reviews = [];
  lat2.LatLng? _position;
  double convertFraction(double fraction) {
    fraction = (fraction * 10).roundToDouble();
    if (fraction < 1) {
      return 0.15;
    } else if (fraction < 2) {
      return 0.32;
    } else if (fraction < 3)
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

  Future<void> _fetchRestaurantDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Assuming that the data is fetched from the Restaurant object directly

    _noteMoyenne = widget.restaurant.ratings.toString();
    _userRatingsTotal = widget.restaurant.numberOfReviews;
    _photoReference = widget.restaurant.pictureProfile;
    _siteInternet = widget.restaurant.websiteUrl;
    _cuisine = widget.restaurant.cuisine;
    _position =
        lat2.LatLng(widget.restaurant.latitude, widget.restaurant.longitude);
    try {
      _price = int.parse(widget.restaurant.price);
    } catch (e) {
      print("Erreur de conversion : $e");
    }
    // _instagram = widget.restaurant.instagram;
    _schedule = widget.restaurant.schedule;
    _reviews =
        widget.restaurant.reviews; // Assign reviews from Restaurant object

    print("*****************");
    print('----');

    print(_schedule);
    print("*****************");
    print('----');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _launchUrl(String? url) async {
    if (url != null && await canLaunch(url)) {
      // Utiliser canLaunch avec un String
      await launch(url); // Utiliser launch avec un String
    }
  }

  Future<void> openURL(BuildContext context, String? url) async {
    if (url != null && url.isNotEmpty) {
      String updatedUrl = url.replaceAll("http:", "https:");
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              'Yummap Navigator',
              style: AppTextStyles.titleDarkStyle,
            ),
          ),
          body: SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: WebUri(updatedUrl, forceToStringRawValue: true)),
            ),
          ),
        ),
      ));
    } else {
      // Afficher un toast "Indisponible" si l'URL est vide
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indisponible'),
        ),
      );
    }
  }

  static void _navigateToReviewDetails(
      BuildContext context, Restaurant restaurant, List<ReviewRestau> reviews) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReviewDetailsWidget(restaurant: restaurant, reviews: reviews),
      ),
    );
  }

  List<Widget> buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    double fraction = rating - fullStars;

    // Ajouter les étoiles pleines
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: AppColors.orangeBG));
    }

    // Ajouter l'étoile partiellement remplie si nécessaire
    if (fraction > 0) {
      stars.add(Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRect(
              clipper: FractionalClipper(convertFraction(fraction)),
              child: Icon(Icons.star, size: 25, color: AppColors.orangeBG),
            ),
            Icon(Icons.star,
                size: 25, color: AppColors.orangeBG.withOpacity(0.3))
          ],
        ),
      ));
    }

    // Ajouter les étoiles vides pour compléter la note sur 5
    for (int i = stars.length; i < 5; i++) {
      stars.add(Icon(Icons.star, color: AppColors.orangeBG.withOpacity(0.3)));
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.restaurant.name,
            style: AppTextStyles.titleDarkStyle,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.network(
                          _photoReference,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromRGBO(0, 0, 0, 0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                bottom: 15), // Ajout de la marge en bas
                            alignment:
                                Alignment.bottomCenter, // Alignement en bas
                            child: Text(
                              widget.restaurant.name,
                              style: AppTextStyles.titleWhiteStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //const Icon(Icons.star, color: Colors.amber),
                          Row(
                              children:
                                  buildStarRating(double.parse(_noteMoyenne))),
                          const SizedBox(width: 5),
                          Text(
                            '$_noteMoyenne ($_userRatingsTotal avis)',
                            style: AppTextStyles.paragraphDarkStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations :',
                            style: AppTextStyles.titleDarkStyle,
                          ),
                          const SizedBox(height: 10),
                          Visibility(
                            visible: _price !=
                                0, // Rendre le widget visible si _price est valide
                            child: Row(
                              children: [
                                const Icon(Icons.payment), // Icône de paiement
                                const SizedBox(width: 5),
                                Text(
                                  '€' *
                                      _price, // Affichage du symbole € selon la valeur de price
                                  style: AppTextStyles.paragraphDarkStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                  Icons.local_dining), // Icône de la cuisine
                              const SizedBox(width: 5),
                              Text(
                                _cuisine ??
                                    'Cuisine non spécifiée', // Exemple de type de cuisine
                                style: AppTextStyles.paragraphDarkStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(widget.restaurant.handicap
                                  ? Icons
                                      .accessibility // Si accessible aux personnes à mobilité réduite
                                  : Icons
                                      .not_accessible), // Si non accessible aux personnes à mobilité réduite
                              const SizedBox(width: 5),
                              Text(
                                widget.restaurant.handicap
                                    ? 'Adapté à la mobilité réduite'
                                    : 'Non adapté à la mobilité réduite',
                                style: AppTextStyles.paragraphDarkStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Visibility(
                            visible: widget.restaurant
                                .vege, // Masquer le widget si vege est false
                            child: const Row(
                              children: [
                                Icon(Icons.eco), // Afficher l'icône eco
                                SizedBox(width: 5),
                                Text(
                                  'Propose des plats végétariens',
                                  style: AppTextStyles.paragraphDarkStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 130,
                            child: HorairesRestaurant(
                              schedule: _schedule ??
                                  [], // Utilisation de l'opérateur ?? pour fournir une valeur par défaut
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.menu_book),
                                  title: const Text(
                                    'Menu',
                                    style: AppTextStyles.paragraphDarkStyle,
                                  ),
                                  onTap: () {
                                    openURL(context, _siteInternet);
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: Text(
                                    widget.restaurant.phoneNumber.isNotEmpty
                                        ? widget.restaurant.phoneNumber
                                        : 'Indisponible',
                                    style: AppTextStyles.paragraphDarkStyle,
                                  ),
                                  onTap: () {
                                    if (widget
                                        .restaurant.phoneNumber.isNotEmpty) {
                                      launch(
                                          'tel://${widget.restaurant.phoneNumber}');
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Numéro de téléphone non disponible'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(
                                    widget.restaurant.address,
                                    style: AppTextStyles.paragraphDarkStyle,
                                  ),
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.restaurant.address));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Adresse copiée dans le presse-papiers'),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 200,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      center: _position,
                                      zoom: 18,
                                      maxZoom: 18.4,
                                      minZoom: 1,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        subdomains: const ['a', 'b', 'c'],
                                      ),
                                      MarkerLayer(markers: [
                                        Marker(
                                          point: lat2.LatLng(
                                              widget.restaurant.latitude,
                                              widget.restaurant.longitude),
                                          builder: (ctx) => Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF95A472),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 30.0,
                                            ),
                                          ),
                                        )
                                      ])
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Avis clients :',
                              style: AppTextStyles.titleDarkStyle),
                          const SizedBox(height: 10),
                          if (_reviews.isNotEmpty && _reviews != []) ...[
                            ListTile(
                              title: Text(
                                _reviews[0].text,
                                style: AppTextStyles.paragraphDarkStyle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    '- ${_reviews[0].author}',
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            if (_reviews.length > 1) ...[
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _navigateToReviewDetails(
                                      context, widget.restaurant, _reviews);
                                },
                                child: const Text(
                                  'Voir plus d\'avis',
                                  style: AppTextStyles.paragraphDarkStyle,
                                ),
                              ),
                            ],
                          ] else ...[
                            const Row(
                              children: [
                                Icon(Icons.chat_outlined),
                                SizedBox(width: 10),
                                Text(
                                  'Avis clients indisponibles',
                                  style: AppTextStyles.paragraphDarkStyle,
                                ),
                              ],
                            )
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
