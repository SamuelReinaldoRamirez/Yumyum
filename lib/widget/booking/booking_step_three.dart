import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Pour les animations Lottie
import 'package:yummap/constant/theme.dart';
import 'package:yummap/models/booking_data.dart';

class BookingStepThree extends StatelessWidget {
  final VoidCallback onClose;

  const BookingStepThree({
    Key? key,
    required this.onClose,
    required BookingData bookingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 124),

            // Animation de succès
            Lottie.asset(
              'assets/animations/success_animation.json', // Chemin de l'animation
              width: 200,
              height: 200,
              repeat: false,
            ),

            const SizedBox(height: 24),

            // Message de confirmation
            const Text(
              'Réservation confirmée !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            const SizedBox(height: 16),

            // Message complémentaire
            const Text(
              'Vous recevrez bientôt un email de confirmation.\nMerci de nous faire confiance.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Bouton Fermer
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
