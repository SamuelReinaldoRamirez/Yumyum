import 'package:flutter/material.dart';
import 'booking/booking_step_one.dart';
import 'booking/booking_step_two.dart';
import 'booking/booking_step_three.dart';
import '../models/booking_data.dart';
import '../constant/theme.dart';

class BookingButton extends StatefulWidget {
  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  final BookingData bookingData = BookingData(
    covers: 2, 
    date: DateTime.now(), 
    timeSlot: '12:00 (Disponible)', 
    title: 'Monsieur', 
    firstName: 'Jean', 
    lastName: 'Dupont', 
    phone: '0123456789', 
    email: 'jean.dupont@example.com', 
  );
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 5,
      ),
      onPressed: () => _showBookingDialog(),
      child: Text(
        'Réserver',
        style: TextStyle(
          fontFamily: AppFonts.titleFontFamily,
          fontSize: 18,
        ),
      ),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black, width: 2),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              BookingStepOne(
                bookingData: bookingData,
                onNext: () => _nextPage(),
                onClose: () {
                  Navigator.pop(context);
                  _pageController.dispose();
                },
              ),
              BookingStepTwo(
                bookingData: bookingData,
                onNext: () => _nextPage(),
                onBack: () => _previousPage(),
                onClose: () {
                  Navigator.pop(context);
                },
              ),
              BookingStepThree(
                bookingData: bookingData,
                onClose: () {
                  Navigator.pop(context);
                  _pageController.dispose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
      _pageController.jumpToPage(_currentPage);
    });
  }

  void _previousPage() {
    setState(() {
      _currentPage--;
      _pageController.jumpToPage(_currentPage);
    });
  }
}
