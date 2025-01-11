import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/restaurant.dart';

class RestaurantPinGenerator {
  static Marker getPinMarker(
      String cuisine,
      LatLng position,
      Function(BuildContext, Restaurant) showMarkerInfo,
      Restaurant restaurant,
      bool isOpen) {
    return Marker(
      point: position,
      builder: (ctx) {
        final Color pinBackgroundColor =
            isOpen ? Colors.white : Colors.grey[300]!;
        final Color circleColor =
            isOpen ? AppColors.secondaryColor : Colors.grey[600]!;
        return GestureDetector(
          onTap: () => showMarkerInfo(ctx, restaurant),
          child: buildPinIcon(cuisine, isOpen, pinBackgroundColor, circleColor),
        );
      },
    );
  }

  static Widget buildPinIcon(String cuisine, bool isOpen,
      Color pinBackgroundColor, Color circleColor) {
    // Si le restaurant est fermé, assombrir la couleur de fond du pin
    if (!isOpen) {
      circleColor = Colors.blueGrey; // Ajustez l'opacité selon vos besoins
    }

    Widget icon;
    switch (cuisine) {
      case 'Cuisine française':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/mushroom.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine asiatique':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/bamboo.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine africaine':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/ananas.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Boulangerie':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/croissant.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Pizzeria':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/pizza.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine US':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/hot_dog.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine fusion':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/intersection.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Café':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    Image.asset('assets/icons/cafe.png', width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine orientale':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/tajine.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Cuisine italienne':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/tomate.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      case 'Fast Food':
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/burger.png',
                    width: 20, height: 20),
              ),
            ),
          ),
        );
        break;
      default:
        icon = DecoratedBox(
          decoration: BoxDecoration(
            color: pinBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 20,
                  color: AppColors.appPrimary,
                ),
              ),
            ),
          ),
        );
    }
    return icon;
  }
}
