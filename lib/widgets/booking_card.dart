import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../constant/theme.dart';
import '../pages/booking_detail_page.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailPage(booking: booking),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.restaurantName,
                style: AppTextStyles.titleDarkStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '${booking.dateTime.toLocal().toString().split(' ')[0]} - ${booking.dateTime.hour}:${booking.dateTime.minute}',
                    style: AppTextStyles.hintTextDarkStyle,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '${booking.numberOfPeople} personnes',
                    style: AppTextStyles.hintTextDarkStyle,
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
