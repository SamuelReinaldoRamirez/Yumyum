import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import '../../models/booking_data.dart';

class BookingStepThree extends StatelessWidget {
  final BookingData bookingData;
  final VoidCallback onClose;

  BookingStepThree({required this.bookingData, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Confirmation',
            style: TextStyle(
              fontFamily: AppFonts.titleFontFamily,
              fontSize: 18,
            )),
        // Affichez les détails de la réservation ici
        ElevatedButton(
          onPressed: onClose,
          child: Text('Fermer'),
        ),
      ],
    );
  }
}
