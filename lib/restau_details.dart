import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/reviews_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RestaurantDetailsWidget extends StatefulWidget {
  @override
  _RestaurantDetailsWidgetState createState() => _RestaurantDetailsWidgetState();
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
// class FractionalClipper2 extends CustomClipper<Rect> {
//   final double fraction;

//   FractionalClipper2(this.fraction);

//   @override
//   Rect getClip(Size size) {
//     return Rect.fromLTRB(size.width * fraction, 0, size.width, size.height);
//   }

//   @override
//   bool shouldReclip(FractionalClipper oldClipper) {
//     return oldClipper.fraction != fraction;
//   }
// }

class _RestaurantDetailsWidgetState extends State<RestaurantDetailsWidget> {
  String _photoReference = '';
  bool _isLoading = false;
  String _noteMoyenne = "";
  String _prixMoyen = "";
  Uri _siteInternet = Uri.parse("");
  List<dynamic> _openingHours = [];
  bool _isTimmyCompliant = false;
  bool _isPlantEaterCompliant = false;
  int _userRatingsTotal = 0;
  double _noteDeTeste = 1.1;

double convertFraction(fraction){
    fraction = (fraction * 10).round();
    if(fraction<1)
      return 0.15;
    else if(fraction<2)
      return 0.32;
    else if(fraction<3)
      return 0.35;
    else if(fraction<4)
      return 0.40;
    else if(fraction<5)
      return 0.45;
    else if(fraction==5)
      return 0.5;
    else if(fraction>=9)
      return 0.80;
    else if(fraction>=8)
      return 0.65;
    else if(fraction>=7)
      return 0.60;
    else if(fraction>=6)
      return 0.55;
    else if(fraction<6)
      return 0.52;
    return 0.5;
  }
  
  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  Future<void> _fetchRestaurantDetails() async {
    String placeId = 'ChIJ2SnopiVt5kcRCpl04SjBTuY'; // Remplacez par votre place ID
    String apiKey = 'AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U'; // Remplacez par votre clé d'API Google
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> photosData = data['result']['photos'];
        _noteMoyenne = data['result']['rating'].toString() ?? 'Non disponible';
        _prixMoyen = data['result']['price_level'].toString() ?? 'Non disponible';
        _siteInternet = (Uri.parse(data['result']['website']) ?? null)!;
        _openingHours = data['result']['opening_hours']['weekday_text'];
        _isTimmyCompliant = data['result']['wheelchair_accessible_entrance'];
        _isPlantEaterCompliant = data['result']['serves_vegetarian_food'];
        _userRatingsTotal = data['result']['user_ratings_total'];
        
        print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        print(_isTimmyCompliant);
        if (photosData.isNotEmpty) {
          _photoReference = photosData[0]['photo_reference'];
          print('____________________');
          print(_photoReference);
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

  static void _navigateToReviewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsWidget()),
        // builder: (context) => DetailsTags(restaurant: restaurant)),
    );
  }

//   List<Widget> buildStarRating2(double rating) {
//   List<Widget> stars = [];
//   int fullStars = rating.floor();
//   double fraction = rating - fullStars;

//   // Ajouter les étoiles pleines
//   for (int i = 0; i < 10; i++) {
//     print("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY");
//     print(i+1);
//     print(convertFraction((i+1)/10));
//     stars.add(
//       Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: <Widget>[
//             ClipRect(
//               clipper: FractionalClipper(convertFraction((i+1)/10)),
//               // child: Icon(Icons.star, color: Colors.amber),
//               child: Icon(Icons.star, size: 25, color: Colors.amber),
//             ),
//             // ClipRect(
//             //   clipper: FractionalClipper2(convertFraction(fraction)),
//             //   // child: Icon(Icons.star, color: Colors.amber),
//             //   child: Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.3)),
//             // )
//             Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.3))
//           ],
//         ),
//       )
//       // Icon(Icons.star_half, color: Colors.amber)
//       );
//   }
//   return stars;
// }

  
  List<Widget> buildStarRating(double rating) {
  List<Widget> stars = [];
  int fullStars = rating.floor();
  double fraction = rating - fullStars;

  // Ajouter les étoiles pleines
  for (int i = 0; i < fullStars; i++) {
    stars.add(Icon(Icons.star, color: Colors.amber));
  }

  // Ajouter l'étoile partiellement remplie si nécessaire
  if (fraction > 0) {
    print("FRACTIONNNNNNNNNNNNNNNNNN");
    print(fraction);
    print(convertFraction(fraction));
    stars.add(
      Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRect(
              clipper: FractionalClipper(convertFraction(fraction)),
              // child: Icon(Icons.star, color: Colors.amber),
              child: Icon(Icons.star, size: 25, color: Colors.amber),
            ),
            // ClipRect(
            //   clipper: FractionalClipper2(convertFraction(fraction)),
            //   // child: Icon(Icons.star, color: Colors.amber),
            //   child: Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.3)),
            // )
            Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.3))
          ],
        ),
      )
      // Icon(Icons.star_half, color: Colors.amber)
      );
  }

  // Ajouter les étoiles vides pour compléter la note sur 5
  for (int i = stars.length; i < 5; i++) {
    stars.add(Icon(Icons.star, color: Colors.amber.withOpacity(0.3)));
  }

  return stars;
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bao Express'),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            //photo, note moyenne et prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photoReference.isNotEmpty
          ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  margin: EdgeInsets.only(left: 16, top: 16), // Ajustez la marge comme nécessaire
                  width: 110,
                  height: 110,
                  child: ClipOval(
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$_photoReference&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U',
                      // 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$_photoReference&key=YOUR_API_KEY',
                      fit: BoxFit.cover,
                    ),
                )
          )
          : Center(child: Text('Aucune photo disponible')),

          SizedBox(width: 10),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),


                Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _navigateToReviewDetails(context);
                  },
                  child: Text(
                  // 'Note moyenne: $_noteMoyenne',
                  '$_noteMoyenne',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue,),
                ), 
                               ),
                Row(children: buildStarRating(
                  double.parse(_noteMoyenne)
                  )
                ), 
                Text(
                  // 'Note moyenne: $_noteMoyenne',
                  '($_userRatingsTotal)',
                  style: TextStyle(fontSize: 15, color: Colors.black,),
                ),
                // initialRating: double.parse("3.6".substring(0,"3.6".indexOf("."))), // Note initiale

                // Center(
                //   child: RatingBar.builder(
                //     initialRating: double.parse("3.6"), // Note initiale
                //     itemCount: 5,
                //     itemBuilder: (context, _) => Icon(
                //       Icons.star,
                //       color: Colors.amber,
                //     ),
                //     itemSize: 25,
                //     // allowHalfRating: true, // Autoriser les demi-étoiles
                //     // unratedColor: Colors.amber.withOpacity(0.3), // Couleur vide des étoiles avec une opacité de 30%
                //     onRatingUpdate: (rating) {
                //       print(rating); // Mise à jour de la note lors du glissement de la barre de notation
                //     },
                //   ),
                // ),




                // Center(
                //   child: RatingBar.builder(
                //     initialRating: double.parse("3.6"), // Note initiale
                //     itemCount: 5,
                //     itemBuilder: (context, index) {
                //       IconData iconData;
                //       Color color;
                //       double rating = double.parse("3.6");        
                //       if (index < rating.floor()) {
                //         // Étoile entièrement remplie
                //         iconData = Icons.star;
                //         color = Colors.amber;  
                //       } else if (index == rating.floor()) {
                //         // Dernière étoile avec une fraction de remplissage
                //         double fraction = rating - rating.floor();
                //         if (fraction >= 0.75) {
                //           iconData = Icons.star;
                //           color = Colors.amber;
                //         } else if (fraction >= 0.25) {
                //           iconData = Icons.star_half;
                //           color = Colors.amber;
                //         } else {
                //           iconData = Icons.star;
                //           color = Colors.amber;
                //         }
                //       } else {
                //         // Étoile vide
                //         iconData = Icons.star_border;
                //         color = Colors.amber;
                //       }

                //       return Icon(
                //         iconData,
                //         color: color,
                //         size: 25,
                //       );
                //     },
                //     itemSize: 25,
                //     allowHalfRating: true, // Autoriser les demi-étoiles
                //     unratedColor: Colors.amber.withOpacity(0.7), // Couleur vide des étoiles avec une opacité de 30%
                //     onRatingUpdate: (rating) {
                //       print(rating); // Mise à jour de la note lors du glissement de la barre de notation
                //     },
                //   ),
                // ),


                // Center(
                //     child: Stack(
                //       alignment: Alignment.center,
                //       children: <Widget>[
                //         ClipRect(
                //           clipper: FractionalClipper(0.4),
                //           // child: Icon(Icons.star, color: Colors.amber),
                //           child: Icon(Icons.star, size: 25, color: Colors.amber),
                //         ),
                //         ClipRect(
                //           clipper: FractionalClipper2(0.4),
                //           // child: Icon(Icons.star, color: Colors.amber),
                //           child: Icon(Icons.star, size: 25, color: Colors.amber.withOpacity(0.5)),
                //         )
                //       ],
                //     ),
                //   )


                // ClipRect(
                //     clipper: FractionalClipper(0.4),
                //     // child: Icon(Icons.star, color: Colors.amber),
                //     child: Icon(Icons.star, color: Colors.amber),
                //   ),
                // ClipRect(
                //     clipper: FractionalClipper2(0.4),
                //     // child: Icon(Icons.star, color: Colors.amber),
                //     child: Icon(Icons.star, color: Colors.amber.withOpacity(0.5)),
                //   )

                // for (int i = 0; i < double.parse(_noteMoyenne).truncate(); i++)
                // Icon(
                //   Icons.star,
                //   color: Colors.yellow,
                // ),
              ]
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Text(
                  //   // 'prix moyen: $_prixMoyen',
                  //   'prix : ',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                  // ),
                  for (int i = 0; i < int.parse(_prixMoyen); i++)
                  Icon(
                    Icons.euro_symbol, // Icône "euro" pour le symbole de l'euro
                    color: Colors.blue,
                  ),
                  ]
                ),
                ]
              ),
              ]
            ),
                //site internet / menu
                SizedBox(height: 10),
                _siteInternet != null
                    ? InkWell(
                        onTap: () async {
                          // Vérifier si le lien est valide
                          if (await canLaunch(_siteInternet.toString())) {
                            // Ouvrir le lien
                            await launch(_siteInternet.toString());
                          } else {
                            // Gérer les erreurs si le lien n'est pas valide
                            throw 'Impossible d\'ouvrir le lien $_siteInternet';
                          }
                        },
                        child: Text(
                          '${_siteInternet}',
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      )
                    : SizedBox.shrink(),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children :[

                    _isTimmyCompliant?
                    Icon(
                      Icons.accessible, // Icône de fauteuil roulant
                      color: Colors.black,
                    )
                    //TIMMYYY
                    // SizedBox(
                    //   width: 70, // Largeur de l'image
                    //   height: 70, // Hauteur de l'image
                    //   child: Image.network('https://i.pinimg.com/736x/c2/5e/43/c25e43d66f6f5b098b51265a91c3a2cf.jpg'), // Remplacez 'URL_de_votre_image' par l'URL de votre image
                    // )
                    :SizedBox(height: 0),               

                    _isPlantEaterCompliant?
                    Icon(
                      Icons.eco, // Icône "eco" pour symboliser une feuille
                      color: Colors.green,
                    )
                    :SizedBox(height: 0),
                  ]
                ),

                    //horaires :
                    SizedBox(height: 20),
                     Text(
                  'horaires d\'ouverture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Expanded(
          child:ListView.builder(
                  itemCount: _openingHours.length,
                  itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_openingHours[index]),
                  );
                  }
                )
                )

              ],      
          ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Bao Express'),
  //     ),
  //     body: _isLoading
  //       ? Center(child: CircularProgressIndicator())
  //       : _photoReference.isNotEmpty
  //         ? Container(
  //             width: 200,
  //             height: 200,
  //             child: Image.network(
  //               'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$_photoReference&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U',
  //               // 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$_photoReference&key=YOUR_API_KEY',
  //               fit: BoxFit.cover,
  //             ),
  //           )
  //         : Center(child: Text('Aucune photo disponible')),
  //   );
  // }
}

void main() {
  runApp(MaterialApp(
    title: 'Restaurant Details',
    home: RestaurantDetailsWidget(),
  ));
}
