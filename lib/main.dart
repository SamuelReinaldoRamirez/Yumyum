import 'package:flutter/material.dart';
import 'package:yummap/map_page.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/restaurant.dart';
// ignore: library_prefixes
import 'package:yummap/search_bar.dart' as CustomSearchBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  // List restList = await CallEndpointService.getRestaurantsFromXanos();
  // var restListLank = restList[32];
  // restList.clear();
  // restList.add(restListLank);
  // runApp(MyApp(restaurantList: restList.cast<Restaurant>()));

  List<Restaurant> restaurantList =
      (await CallEndpointService.getRestaurantsFromXanos()).cast<Restaurant>();
  runApp(MyApp(restaurantList: restaurantList));
    

}

class MyApp extends StatelessWidget {
  final List<Restaurant> restaurantList;

  const MyApp({Key? key, required this.restaurantList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: CustomSearchBar.SearchBar(
                    onSearchChanged: (value) {},
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.88, // 90% de la hauteur de l'écran
                  child: MapPage(restaurantList: restaurantList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
