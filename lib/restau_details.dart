import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? _instagram;
  String? _menu;
  List<List<String>>? _schedule;

  double convertFraction(double fraction) {
    fraction = (fraction * 10).roundToDouble();
    if (fraction < 1) {
      return 0.15;
    } else if (fraction < 2)
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

  Future<void> _fetchRestaurantDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Assuming that the data is fetched from the Restaurant object directly

    _noteMoyenne = widget.restaurant.ratings.toString();
    _userRatingsTotal = widget.restaurant.numberOfReviews;
    _photoReference = widget.restaurant.pictureProfile;
    _siteInternet = widget.restaurant.websiteUrl;
    // _instagram = widget.restaurant.instagram;
    _menu = widget.restaurant.websiteUrl;
    _schedule = widget.restaurant.schedule;
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
    if (url != null) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Yummap Navigator'),
          ),
          body: SafeArea(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(url, forceToStringRawValue: true)),
            ),
          ),
        ),
      ));
    }
  }

  static void _navigateToReviewDetails(
      BuildContext context, Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsWidget(restaurant: restaurant),
      ),
    );
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
                            style: const TextStyle(
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text(
                          '$_noteMoyenne ($_userRatingsTotal avis)',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 20), // Ajout d'un espace
                        IconButton(
                          icon: const Icon(Icons.language),
                          onPressed: () {
                            openURL(context, _siteInternet);
                            //_launchUrl(_siteInternet);
                            print(_siteInternet);
                            print("--------------------------");
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_camera_outlined),
                          onPressed: () {
                            _launchUrl(_instagram);
                          },
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.local_dining), // Icône de la cuisine
                            SizedBox(width: 5),
                            Text(
                              'Cuisine française', // Exemple de type de cuisine
                              style: TextStyle(fontSize: 16),
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
                            SizedBox(width: 5),
                            Text(
                              widget.restaurant.handicap
                                  ? 'Adapté à la mobilité réduite'
                                  : 'Non adapté à la mobilité réduite',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(widget.restaurant.vege
                                ? Icons.eco // Si propose des plats végétariens
                                : Icons
                                    .not_interested_sharp), // Si ne propose pas de plats végétariens
                            SizedBox(width: 5),
                            Text(
                              widget.restaurant.vege
                                  ? 'Propose des plats végétariens'
                                  : 'Ne propose pas de plats végétariens',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
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
                                leading: const Icon(Icons.phone),
                                title: Text(
                                    widget.restaurant.phoneNumber.isNotEmpty
                                        ? widget.restaurant.phoneNumber
                                        : 'Indisponible'),
                                onTap: () {
                                  if (widget
                                      .restaurant.phoneNumber.isNotEmpty) {
                                    launch(
                                        'tel://${widget.restaurant.phoneNumber}');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                leading: const Icon(Icons.menu_book),
                                title: const Text('Menu'),
                                onTap: () {
                                  _launchUrl(_menu);
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(widget.restaurant.address),
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: widget.restaurant.address));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Adresse copiée dans le presse-papiers'),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 200,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(widget.restaurant.latitude,
                                        widget.restaurant.longitude),
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId:
                                          const MarkerId('restaurant_location'),
                                      position: LatLng(
                                          widget.restaurant.latitude,
                                          widget.restaurant.longitude),
                                      infoWindow: const InfoWindow(
                                        title: 'Restaurant',
                                        snippet: '123 Rue du Restaurant, Ville',
                                      ),
                                    ),
                                  },
                                  mapType: MapType.normal,
                                  myLocationEnabled: true,
                                  zoomControlsEnabled: false,
                                  onMapCreated:
                                      (GoogleMapController controller) {},
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
                        const Text(
                          'Avis clients :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const ListTile(
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
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _navigateToReviewDetails(
                                context, widget.restaurant);
                          },
                          child: const Text('Voir plus d\'avis'),
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
