import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yummap/reviews_details.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailsWidget extends StatefulWidget {
  @override
  _RestaurantDetailsWidgetState createState() => _RestaurantDetailsWidgetState();
}

class _RestaurantDetailsWidgetState extends State<RestaurantDetailsWidget> {
  String _photoReference = '';
  bool _isLoading = false;
  String _noteMoyenne = "";
  String _prixMoyen = "";
  Uri _siteInternet = Uri.parse("");
  List<dynamic> _openingHours = [];
  bool _isTimmyCompliant = false;
  bool _isPlantEaterCompliant = false;


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
                  'Note : ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue,),
                )
                ),
                for (int i = 0; i < double.parse(_noteMoyenne).truncate(); i++)
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
              ]
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    // 'prix moyen: $_prixMoyen',
                    'prix : ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                  ),
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
                    // Icon(
                    //   Icons.accessible, // Icône de fauteuil roulant
                    //   color: Colors.blue,
                    // )
                    SizedBox(
                      width: 70, // Largeur de l'image
                      height: 70, // Hauteur de l'image
                      child: Image.network('https://i.pinimg.com/736x/c2/5e/43/c25e43d66f6f5b098b51265a91c3a2cf.jpg'), // Remplacez 'URL_de_votre_image' par l'URL de votre image
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
