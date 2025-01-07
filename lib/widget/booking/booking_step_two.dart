import 'package:flutter/material.dart';
import '../../models/booking_data.dart';
import '../neubrutalist/neubrutalist_button.dart';

class BookingStepTwo extends StatelessWidget {
  final BookingData bookingData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  BookingStepTwo(
      {required this.bookingData, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Informations de contact',
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
              fontSize: 18,
            )),
        // Ajoutez des champs de formulaire ici
        NeubrutalistButton(
          onPressed: onBack,
          child: Text('Retour'),
        ),
        NeubrutalistButton(
          onPressed: onNext,
          child: Text('Réserver'),
        ),
      ],
    );
  }
}
