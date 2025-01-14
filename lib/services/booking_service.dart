import '../models/booking_model.dart';

class BookingService {
  Future<List<BookingModel>> getUserBookings() async {
    await Future.delayed(Duration(seconds: 2)); // Simule un délai de chargement
    return [
      BookingModel(
        id: '1',
        restaurantName: 'Restaurant A',
        restaurantImage: 'image_url',
        dateTime: DateTime.now(),
        numberOfPeople: 2,
        status: 'Confirmé',
        userName: 'John Doe',
        userPhone: '123456789',
      ),
      // Ajoutez d'autres réservations si nécessaire
    ];
  }
}
