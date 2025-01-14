import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constant/theme.dart';
import '../widgets/booking_card.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widget/neu_brutalism_container.dart';

class BookingListPage extends ConsumerWidget {
  const BookingListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsyncValue = ref.watch(bookingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text('Mes réservations', style: AppTextStyles.titleDarkStyle),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bookingsAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Erreur: ${error.toString()}',
            style: AppTextStyles.hintTextDarkStyle,
          ),
        ),
        data: (List<BookingModel> bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'Aucune réservation',
                style: AppTextStyles.hintTextDarkStyle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return NeuBrutalismContainer(
                child: BookingCard(booking: booking),
              );
            },
          );
        },
      ),
    );
  }
}
