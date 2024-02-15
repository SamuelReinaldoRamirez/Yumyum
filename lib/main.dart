import 'package:flutter/material.dart';
import 'package:yummap/order_tracking_page.dart';
import 'package:yummap/call_endpoint_service.dart'; // Import the service file
import 'package:yummap/Restaurant.dart'; // Import the Restaurant model

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Call the endpoint service to get the restaurants
  List<Restaurant> restaurantList =
      await CallEndpointService.getRestaurantsFromXanos();
  runApp(MyApp(
      restaurantList: restaurantList)); // Pass the restaurant list to MyApp
}

class MyApp extends StatelessWidget {
  final List<Restaurant> restaurantList; // Define the restaurant list

  const MyApp({Key? key, required this.restaurantList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yumyum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // Pass the restaurant list to the OrderTrackingPage
      home: OrderTrackingPage(restaurantList: restaurantList),
    );
  }
}
