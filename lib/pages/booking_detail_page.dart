import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../constant/theme.dart';

class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text('Détails de la réservation',
            style: AppTextStyles.titleDarkStyle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.restaurantName, style: AppTextStyles.titleDarkStyle),
            SizedBox(height: 16),
            _buildInfoRow('Date', booking.dateTime.toString()),
            _buildInfoRow('Personnes', booking.numberOfPeople.toString()),
            _buildInfoRow('Statut', booking.status),
            _buildInfoRow('Client', booking.userName),
            _buildInfoRow('Téléphone', booking.userPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.hintTextDarkStyle),
          Text(value,
              style: AppTextStyles.paragraphDarkStyle.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
