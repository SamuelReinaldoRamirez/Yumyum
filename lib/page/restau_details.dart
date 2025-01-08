// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat2;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/review.dart';
import 'package:yummap/model/review_interface.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/widget/booking/booking_step_one.dart';
import 'package:yummap/widget/booking/booking_step_three.dart';
import 'package:yummap/widget/booking/booking_step_two.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import '../model/restaurant.dart';
import '../widget/reviews_details.dart';
import '../widget/horaires_restaurant.dart';
import '../widget/neu_brutalism_container.dart'; // Importer le fichier qui contient la classe NeuBrutalismContainer
import '../models/booking_data.dart'; // Importation de BookingData

class RestaurantDetailsWidget extends StatefulWidget {
  const RestaurantDetailsWidget({super.key, required this.restaurant});

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
  Map<String, List<String>>? _schedule;
  List<ReviewRestau> _reviews = [];
  List<Review> _workspaceReviews = [];
  lat2.LatLng? _position;
  final PageController _pageController = PageController();
  late BookingData bookingData;
  int currentStep = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentStep++;
    });
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentStep--;
    });
  }

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
    bookingData = BookingData(
      covers: 2,
      date: DateTime.now(),
      timeSlot: '12:00 (Disponible)',
      title: 'Monsieur',
      firstName: 'Jean',
      lastName: 'Dupont',
      phone: '0123456789',
      email: 'jean.dupont@example.com',
      comment: '',
      saveInfo: false,
      acceptTerms: false,
    );
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

  List<Widget> buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    double fraction = rating - fullStars;

    // Ajouter les étoiles pleines
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: AppColors.primaryColor));
    }

    // Ajouter l'étoile partiellement remplie si nécessaire
    if (fraction > 0) {
      stars.add(Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRect(
              clipper: FractionalClipper(convertFraction(fraction)),
              child: Icon(Icons.star, size: 25, color: AppColors.primaryColor),
            ),
            Icon(Icons.star,
                size: 25, color: AppColors.primaryColor.withOpacity(0.3))
          ],
        ),
      ));
    }

    // Ajouter les étoiles vides pour compléter la note sur 5
    for (int i = stars.length; i < 5; i++) {
      stars.add(
          Icon(Icons.star, color: AppColors.primaryColor.withOpacity(0.3)));
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
    // Vérifiez si des avis sont disponibles
    final hasReviews = reviews.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec le titre et l'icône Google
          if (hasReviews) // Afficher l'en-tête seulement s'il y a des avis
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (isGoogleReview) const SizedBox(width: 8),
                  Text(
                    isGoogleReview
                        ? 'Avis Google'
                        : title, // Remplacer le titre ici
                    style: AppTextStyles.titleDarkStyle.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

          // Liste des avis
          if (hasReviews) // Afficher la liste des avis seulement s'il y a des avis
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 3 ? 3 : reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.secondaryColor,
                              child: Text(
                                review.author[0].toUpperCase(),
                                style: AppTextStyles.titleDarkStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.author,
                                    style:
                                        AppTextStyles.titleDarkStyle.copyWith(
                                      color: AppColors.textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: buildStarRating(
                                        review.rating.toDouble()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (review.comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: AppTextStyles.paragraphDarkStyle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

          // Bouton "Voir plus"
          if (reviews.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () =>
                    _navigateToReviewDetails(context, restaurant, reviews),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'Voir plus d\'avis',
                    style: AppTextStyles.titleDarkStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant en dehors
      barrierLabel: "BookingDialog",
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0), // Espacement à gauche
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Fermer le dialog
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor, // Cercle semi-transparent
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white, // Couleur de l'icône
                    size: 20,
                  ),
                ),
              ),
            ),
            title: Center(
              child: Text(
                "Réservations",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height, // Prend toute la hauteur
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BookingStepOne(
                    bookingData: bookingData,
                    onNext: () => _nextPage(),
                    onClose: () =>
                        Navigator.of(context).pop(), // Fermer le dialog
                  ),
                  BookingStepTwo(
                    bookingData: bookingData,
                    onNext: () => _nextPage(),
                    onBack: () => _previousPage(),
                    onClose: () => Navigator.of(context).pop(), // Ajout de onClose
                  ),
                  BookingStepThree(
                    bookingData: bookingData,
                    onClose: () {
                      setState(() {
                        currentStep = 0;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration:
          const Duration(milliseconds: 300), // Durée de la transition
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Animation depuis le bas de l'écran
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
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
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          title: Text(
            widget.restaurant.name,
            style: AppTextStyles.titleBlueStyle.copyWith(
              color: AppColors.primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        backgroundColor: AppColors.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Image with overlay
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
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
                                      Colors.black,
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.45],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              child: SizedBox(
                                width: MediaQuery.of(context)
                                    .size
                                    .width, // Prendre toute la largeur de l'écran
                                child: Text(
                                  widget.restaurant.name,
                                  style: AppTextStyles.titleWhiteStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines:
                                      2, // Permet d'afficher jusqu'à 2 lignes
                                  overflow: TextOverflow
                                      .visible, // Ne pas couper le texte
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ratings
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                children: buildStarRating(
                                    double.parse(_noteMoyenne))),
                            const SizedBox(width: 8),
                            Text(
                              '$_noteMoyenne ($_userRatingsTotal avis)',
                              style: AppTextStyles.paragraphDarkStyle,
                            ),
                          ],
                        ),
                      ),

                      // Additional Information
                      NeuBrutalismContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations :',
                              style: AppTextStyles.titleDarkStyle,
                            ),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: _price !=
                                  0, // Rendre le widget visible si _price est valide
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.payment,
                                    color: AppColors.textColor,
                                  ), // Icône de paiement
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
                                const Icon(Icons.local_dining,
                                    color: AppColors
                                        .textColor), // Icône de la cuisine
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
                                Icon(
                                    widget.restaurant.handicap
                                        ? Icons
                                            .accessibility // Si accessible aux personnes à mobilité réduite
                                        : Icons.not_accessible,
                                    color: AppColors
                                        .textColor), // Si non accessible aux personnes à mobilité réduite
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
                                  Icon(Icons.eco,
                                      color: AppColors
                                          .textColor), // Afficher l'icône eco
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
                                schedule:
                                    _schedule!, // Utilisation de l'opérateur ?? pour fournir une valeur par défaut
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(height: 20),
                            Center(
                              child: CustomNeuButton(
                                icon: Icons.calendar_month,
                                text: 'Réserver',
                                onPressed: () {
                                  _showBookingDialog();
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.menu_book,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(
                                      'Menu',
                                      style:
                                          AppTextStyles.titleDarkStyle.copyWith(
                                        fontSize: 18,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      openURL(context, _siteInternet);
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.phone,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(
                                      widget.restaurant.phoneNumber.isNotEmpty
                                          ? widget.restaurant.phoneNumber
                                          : 'Indisponible',
                                      style:
                                          AppTextStyles.titleDarkStyle.copyWith(
                                        fontSize: 18,
                                        color: AppColors.secondaryColor,
                                      ),
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
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(
                                      widget.restaurant.address,
                                      style:
                                          AppTextStyles.titleDarkStyle.copyWith(
                                        fontSize: 18,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: widget.restaurant.address));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                      if (_workspaceReviews
                          .isNotEmpty) // Afficher la section des avis des hôtels seulement s'il y a des avis
                        buildReviewContainer(
                          context: context,
                          title: 'Avis des Hôtels :',
                          reviews: _workspaceReviews,
                          restaurant: widget.restaurant,
                          isGoogleReview: false,
                        ),
                      buildReviewContainer(
                        context: context,
                        title: 'Avis Google :',
                        reviews: _reviews,
                        restaurant: widget.restaurant,
                        isGoogleReview: true,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
