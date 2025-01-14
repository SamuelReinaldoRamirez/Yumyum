import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

final bookingProvider = StateNotifierProvider<BookingNotifier, AsyncValue<List<BookingModel>>>((ref) {
  return BookingNotifier(BookingService());
});

class BookingNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final BookingService _bookingService;

  BookingNotifier(this._bookingService) : super(const AsyncValue.loading()) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state = const AsyncValue.loading();
    try {
      final bookings = await _bookingService.getUserBookings();
      state = AsyncValue.data(bookings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
