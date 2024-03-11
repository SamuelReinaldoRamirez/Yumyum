// order_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/map_page.dart';

class OrderTrackingPage extends StatelessWidget {
  final List<Restaurant> restaurantList;

  const OrderTrackingPage({Key? key, required this.restaurantList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Passer uniquement les trois premiers éléments de restaurantList à MapPage
    return MapPage(restaurantList: restaurantList);
  }
}
