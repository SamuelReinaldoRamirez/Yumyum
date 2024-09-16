// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/review.dart';
import 'package:yummap/review_interface.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/translate_utils.dart';
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
  static final CustomTranslate customTranslate = CustomTranslate(); // Ajout de l'instance
  String _photoReference = '';
  bool _isLoading = false;
  String _noteMoyenne = '';
  int _userRatingsTotal = 0;
  String? _siteInternet;
  int _price = 0;
  String? _cuisine;
  Map<String, List<String>>? _schedule;
  List<ReviewRestau> _reviews = [];
  List<Review> _workspaceReviews = [];
  lat2.LatLng? _position;
  double convertFraction(double fraction) {
    fraction = (fraction * 10).roundToDouble();
    if (fraction < 1) {
      return 0.15;
    } else if (fraction < 2) {
      return 0.32;
    } else if (fraction < 3) {
      return 0.35;
    } else if (fraction < 4) {
      return 0.40;
    } else if (fraction < 5) {
      return 0.45;
    } else if (fraction == 5) {
      return 0.5;
    } else if (fraction >= 9) {
      return 0.80;
    } else if (fraction >= 8) {
      return 0.65;
    } else if (fraction >= 7) {
      return 0.60;
    } else if (fraction >= 6) {
      return 0.55;
    } else if (fraction < 6) {
      return 0.52;
    }
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

    _fetchReviewList(widget.restaurant);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchReviewList(Restaurant restaurant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliasListMemory =
        prefs.getStringList('workspaceAliases') ?? [];
    List workspaceIdsList =
        await CallEndpointService().getWorkspaceIdsByAliases(aliasListMemory);
    List<Review> reviews = await CallEndpointService()
        .getReviewsByRestaurantAndWorkspaces(restaurant.id,
            workspaceIdsList.map((item) => item['id'] as int).toList());

    setState(() {
      _workspaceReviews = reviews.cast<Review>();
    });
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
            title: Text(
              "Yummap Navigator".tr(),
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
        SnackBar(
          content: Text("unavailable".tr()),
        ),
      );
    }
  }

  static void _navigateToReviewDetails(BuildContext context,
      Restaurant restaurant, List<ReviewInterface> reviews) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReviewDetailsWidget(restaurant: restaurant, reviews: reviews),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      );
    }
    return Row(children: stars);
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

  Widget buildReviewContainer({
    required BuildContext context,
    required String title,
    required List<ReviewInterface> reviews,
    required Restaurant restaurant,
    required bool isGoogleReview,
  }) {
    // Détermine si on doit afficher le message "Avis indisponibles"
    final showUnavailableMessage = isGoogleReview && reviews.isEmpty;

    // Détermine si on doit afficher le bouton "Voir plus d'avis"
    final showSeeMoreButton = reviews.length > 1;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          if (reviews.isNotEmpty || showUnavailableMessage) ...[
            Text(title, style: AppTextStyles.titleDarkStyle),
            const SizedBox(height: 10),
          ],

          // Gestion de l'affichage selon les avis disponibles
          if (reviews.isNotEmpty) ...[
            // Affiche le premier avis dans une carte
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStarRating(reviews[0]
                            .rating), // Ajoute la fonction pour les étoiles
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Text(
                    //   reviews[0].comment,
                    //   style: const TextStyle(
                    //     fontSize: 16,
                    //     color: Colors.grey,
                    //     fontFamily: 'Poppins',
                    //   ),
                    // ),


//IL FAUT FORCEMENT TRADUIRE LES REVIEWS DEPUIS AUTO
                    context.locale.languageCode == "fr"
                      ? Text(
                          reviews[0].comment,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        )
                      : FutureBuilder<String>(
                          future: customTranslate.translate(
                            reviews[0].comment,
                            "fr",
                            // "auto",
                            context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode,
                          ), // Utilisation de l'instance pour la traduction
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LinearProgressIndicator(); // Affiche une barre de progression 2D pendant la traduction
                            } else if (snapshot.hasError) {
                              return Text(
                                'Erreur de traduction: ${snapshot.error}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? reviews[0].comment, // Affiche le texte traduit ou le commentaire d'origine si la traduction échoue
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                ),
                              );
                            }
                          },
                        ),

                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        reviews[0].author,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Affiche le bouton "Voir plus d'avis" s'il y a plus d'un avis et si c'est nécessaire
            if (showSeeMoreButton) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _navigateToReviewDetails(context, restaurant,
                      reviews); // Fonction pour voir plus d'avis
                },
                child: Text(
                  "see more reviews".tr(),
                  style: AppTextStyles.paragraphDarkStyle,
                ),
              ),
            ],
          ] else if (showUnavailableMessage) ...[
            // Affiche un message si les avis Google sont indisponibles
            Row(
              children: [
                const Icon(Icons.chat_outlined),
                const SizedBox(width: 10),
                Text(
                  "Google reviews unavailable".tr(),
                  style: AppTextStyles.paragraphDarkStyle,
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
                            '$_noteMoyenne ($_userRatingsTotal ' + "reviews)".tr(),
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
                          Text(
                            "informations".tr() + " :",
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
                          // Row(
                          //   children: [
                          //     const Icon(
                          //         Icons.local_dining), // Icône de la cuisine
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       _cuisine ??
                          //           "non precise cuisine".tr(), // Exemple de type de cuisine
                          //       style: AppTextStyles.paragraphDarkStyle,
                          //     ),
                          //   ],
                          // ),


                          Row(
                            children: [
                              const Icon(Icons.local_dining), // Icône de la cuisine
                              const SizedBox(width: 5),
                              (_cuisine != null && _cuisine != "")
                                  ? (context.locale.languageCode == "fr"
                                      ? Text(
                                          _cuisine!, // Affiche le texte d'origine si la langue est "fr"
                                          style: AppTextStyles.paragraphDarkStyle,
                                        )
                                      : FutureBuilder<String>(
                                          future: customTranslate.translate(
                                            _cuisine!,
                                            "fr", 
                                            context.locale.languageCode,
                                          ), // Utilisation de l'instance pour la traduction
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Affiche un indicateur de chargement pendant la traduction
                                            } else if (snapshot.hasError) {
                                              return Text('Erreur de traduction: ${snapshot.error}');
                                            } else {
                                              return Text(
                                                snapshot.data ?? _cuisine!, // Affiche le texte traduit, ou le texte d'origine si la traduction échoue
                                                style: AppTextStyles.paragraphDarkStyle,
                                              );
                                            }
                                          },
                                        ))
                                  : Text(
                                      "non precise cuisine".tr(), // Si _cuisine est null ou vide
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
                                    ? "handi adapted".tr()
                                    : "no handi adapted".tr(),
                                style: AppTextStyles.paragraphDarkStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Visibility(
                            visible: widget.restaurant
                                .vege, // Masquer le widget si vege est false
                            child: Row(
                              children: [
                                const Icon(Icons.eco), // Afficher l'icône eco
                                const SizedBox(width: 5),
                                Text(
                                  "veggi dishes".tr(),
                                  style: AppTextStyles.paragraphDarkStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 130,
                            child: HorairesRestaurant(
                              schedule:
                                  _schedule!, // Utilisation de l'opérateur ?? pour fournir une valeur par défaut
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.menu_book),
                                  title: Text(
                                    "menu".tr(),
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
                                        : "unavailable".tr(),
                                    style: AppTextStyles.paragraphDarkStyle,
                                  ),
                                  onTap: () {
                                    if (widget
                                        .restaurant.phoneNumber.isNotEmpty) {
                                      launch(
                                          "phone.short".tr() + '://${widget.restaurant.phoneNumber}');
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "no phone number".tr()),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  // title: Text(
                                  //   widget.restaurant.address,
                                  //   style: AppTextStyles.paragraphDarkStyle,
                                  // ),
                                  title: context.locale.languageCode == "fr"
                                    ? Text(
                                        widget.restaurant.address,
                                        style: AppTextStyles.paragraphDarkStyle,
                                      )
                                    : FutureBuilder<String>(
                                        future: customTranslate.translate(
                                          widget.restaurant.address,
                                          "fr",
                                          context.locale.languageCode,
                                        ), // Utilisation de l'instance pour la traduction
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return LinearProgressIndicator(); // Affiche une barre de progression 2D pendant la traduction
                                          } else if (snapshot.hasError) {
                                            return Text(
                                              'Erreur de traduction: ${snapshot.error}',
                                              style: AppTextStyles.paragraphDarkStyle,
                                            );
                                          } else {
                                            return Text(
                                              snapshot.data ?? widget.restaurant.address, // Affiche le texte traduit, ou l'adresse d'origine si la traduction échoue
                                              style: AppTextStyles.paragraphDarkStyle,
                                            );
                                          }
                                        },
                                      ),
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.restaurant.address));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "copied in press papier".tr()),
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
                    buildReviewContainer(
                      context: context,
                      title: "${"hotel reviews".tr()} :",
                      reviews: _workspaceReviews,
                      restaurant: widget.restaurant,
                      isGoogleReview: false,
                    ),
                    buildReviewContainer(
                      context: context,
                      title: "${"google reviews".tr()} :",
                      reviews: _reviews,
                      restaurant: widget.restaurant,
                      isGoogleReview: true,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
