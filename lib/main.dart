import 'package:flutter/material.dart';
import 'package:yummap/order_tracking_page.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/Restaurant.dart';
import 'package:yummap/search_bar.dart' as CustomSearchBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Restaurant> restaurantList =
      await CallEndpointService.getRestaurantsFromXanos();
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
          child: Column(
            children: [
              CustomSearchBar.SearchBar(
                onSearchChanged: (value) {
                  print('Recherche: $value');
                },
              ),
              SizedBox(
                // Utiliser un SizedBox pour définir des contraintes de taille pour OrderTrackingPage
                height: MediaQuery.of(context).size.height *
                    0.8, // Ajustez la taille selon vos besoins
                child: OrderTrackingPage(restaurantList: restaurantList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}