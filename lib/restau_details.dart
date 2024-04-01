import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/reviews_details.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailsWidget extends StatefulWidget {

  const RestaurantDetailsWidget({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _RestaurantDetailsWidgetState createState() => _RestaurantDetailsWidgetState(restaurant);
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
  String _prixMoyen = "";
  Uri _siteInternet = Uri.parse("");
  List<dynamic> _openingHours = [];
  bool _isTimmyCompliant = false;
  bool _isPlantEaterCompliant = false;
  int _userRatingsTotal = 0;

  _RestaurantDetailsWidgetState(this.restaurant);

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

  Future<String> fetchPlaceId(Restaurant restaurante) async {
    print("FETCH PLACEID !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    String placeId= "";
    String name = restaurante.name.trim();
    String latitude = restaurante.latitude.toString();
    String longitude = restaurante.longitude.toString();
    try {
      print("SERRRIEUXXX APIKEYYY EN DUUUR???????????");
      print("https://maps.googleapis.com/maps/api/place/textsearch/json?query=$name&location=$latitude,$longitude&radius=500&type=restaurant&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U");
      print("https://maps.googleapis.com/maps/api/place/textsearch/json?query=$name&location=$latitude,$longitude&radius=500&type=restaurant&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U");
      http.Response response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/textsearch/json?query=$name&location=$latitude,$longitude&radius=500&type=restaurant&key=AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print(response.body);
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
    print('YYYYYYYYYYYYYYYYYYYYYYYYY');
    print(this.restaurant);
    print(this.restaurant.name);
    if(this.restaurant.getPlaceId() != Null){
      print("caca");
    }else{
      print("pipi");
    }
    if(this.restaurant.getPlaceId().isNotEmpty){
      print("cucu");
    }else{
      print("pupu");
    }
    print("+"+restaurant.getPlaceId()+"+");
    String placeId = (restaurant.placeId == "") ? await fetchPlaceId(restaurant) : restaurant.placeId ; // Remplacez par votre place ID
    // String placeId = 'ChIJ2SnopiVt5kcRCpl04SjBTuY'; // Remplacez par votre place ID
    print("ATTENTION !!!!!!!!!!!!!!!! IL FAUT REMPLACER L4APIKEY POUR LA MASQUER!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    String apiKey = 'AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U'; // Remplacez par votre clé d'API Google
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    print(url);

    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response = await http.get(Uri.parse(url));
      // print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> photosData = data['result']['photos'];
        print(photosData);
        // print(data['result']['rating']);
        _noteMoyenne = data['result']['rating'] != null ? data['result']['rating'].toString() : '0';
        print(_noteMoyenne);
        _prixMoyen = data['result']['price_level'] != null ? data['result']['price_level'].toString() : '0';
        print(_prixMoyen);
        _siteInternet = (Uri.parse(data['result']['website'] != null ? data['result']['website'] : ""));
        print(_siteInternet);
        _openingHours = data['result']['opening_hours']['weekday_text'];
        print(_openingHours);

        // Type type = data['result']['wheelchair_accessible_entrance'].getType();
        // print('Le type de l\'objet est : $type');


        print(data['result']['wheelchair_accessible_entrance']);
        //_isTimmyCompliant = stringToBool(data['result']['wheelchair_accessible_entrance'].toString());
        _isTimmyCompliant = data['result']['wheelchair_accessible_entrance'] != null ? data['result']['wheelchair_accessible_entrance'] : false;

        print(_isTimmyCompliant);
        // _isPlantEaterCompliant = stringToBool(data['result']['serves_vegetarian_food'].toString());
        _isPlantEaterCompliant = data['result']['serves_vegetarian_food'] != null ? data['result']['serves_vegetarian_food'] : false;
        print(_isPlantEaterCompliant);
        _userRatingsTotal = data['result']['user_ratings_total'];
        // print(photosData);

        print(_noteMoyenne);
        print(_prixMoyen);
        print(_siteInternet);
        print(_openingHours);
        print(_userRatingsTotal);
        if (photosData.isNotEmpty) {
          _photoReference = photosData[0]['photo_reference'];
        }
        print(_photoReference);
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

//   bool stringToBool(String value) {
//     print("stringtoBOOL");
//     print(value);
//   // Convert "true" (case insensitive) to true
//   if (value.toLowerCase() == 'true') {
//     return true;
//   }
//   // Convert "false" (case insensitive) to false
//   else if (value.toLowerCase() == 'false') {
//     return false;
//   }
//   // If the string is neither "true" nor "false", you might handle it differently,
//   // like considering it as false by default or throwing an exception.
//   else {
//     throw FormatException('Invalid boolean string: $value');
//   }
// }

  static void _navigateToReviewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsWidget()),
        // builder: (context) => DetailsTags(restaurant: restaurant)),
    );
  }

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
    stars.add(
      Center(
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
      )
      );
  }

  // Ajouter les étoiles vides pour compléter la note sur 5
  for (int i = stars.length; i < 5; i++) {
    stars.add(Icon(Icons.star, color: Colors.amber.withOpacity(0.3)));
  }

  return stars;
}

Future<void> _launchUrl() async {
  if (!await launchUrl(_siteInternet)) {
    throw Exception('Could not launch $_siteInternet');
  }
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
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
                  '$_noteMoyenne',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue,),
                ), 
                               ),
                Row(children: buildStarRating(
                  double.parse(_noteMoyenne)
                  )
                ), 
                Text(
                  '($_userRatingsTotal)',
                  style: TextStyle(fontSize: 15, color: Colors.black,),
                ),
              ]
                ),
                (_prixMoyen != "0" ) ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  for (int i = 0; i < int.parse(_prixMoyen); i++)
                  Icon(
                    Icons.euro_symbol, // Icône "euro" pour le symbole de l'euro
                    color: Colors.blue,
                  ),
                  ]
                ) : SizedBox(height: 0),
                ]
              ),
              ]
            ),
            SizedBox(height: 10),
                _siteInternet != null && Uri.parse(_siteInternet.toString()).isAbsolute
                ? InkWell(
                    onTap: _launchUrl,
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
}

// void main() {
//   runApp(MaterialApp(
//     title: 'Restaurant Details',
//     home: RestaurantDetailsWidget(),
//   ));
// }
