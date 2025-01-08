import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importation de la bibliothèque Intl pour le formatage de la date
import 'package:yummap/constant/theme.dart';
import 'package:yummap/widget/neu_brutalism_container.dart';
import '../../models/booking_data.dart';
import '../neubrutalist/neubrutalist_button.dart';
import 'package:dotted_border/dotted_border.dart';

class BookingStepOne extends StatefulWidget {
  final BookingData bookingData;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const BookingStepOne({
    Key? key,
    required this.bookingData,
    required this.onNext,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BookingStepOne> createState() => _BookingStepOneState();
}

class _BookingStepOneState extends State<BookingStepOne> {
  late DateTime selectedDate;
  late int selectedCovers;
  bool isCoversExpanded = false; // État pour le nombre de couverts
  bool isDateExpanded = false; // État pour la date
  bool isSlotExpanded = false; // État pour le créneau
  String? selectedSlot; // Heure choisie

  @override
  void initState() {
    super.initState();
    selectedDate = widget.bookingData.date;
    selectedCovers = widget.bookingData.covers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nombre de couverts
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCoversExpanded = !isCoversExpanded;
                  });
                },
                child: NeuBrutalismContainer(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec compteur et icône
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nombre de personnes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedCovers.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.textColor,
                                ),
                              ],
                            ),
                            Icon(
                              isCoversExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: AppColors.textColor,
                            ),
                          ],
                        ),
                        // Contenu qui se déplie si isCoversExpanded est true
                        if (isCoversExpanded) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (selectedCovers > 1) selectedCovers--;
                                  });
                                },
                              ),
                              Text(
                                selectedCovers.toString(),
                                style: const TextStyle(fontSize: 24),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    selectedCovers++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sélection de la date
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDateExpanded = !isDateExpanded;
                  });
                },
                child: NeuBrutalismContainer(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Date de réservation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 30,
                                    color:
                                        AppColors.textColor),
                                const SizedBox(
                                    width:
                                        8),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isDateExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: AppColors.textColor,
                            ),
                          ],
                        ),
                        if (isDateExpanded) ...[
                          const SizedBox(height: 10),
                          Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary:
                                    AppColors.primaryColor,
                                onPrimary: Colors
                                    .white,
                                onSurface: AppColors
                                    .textColor,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppColors.primaryColor,
                                ),
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 30)),
                              onDateChanged: (date) {
                                setState(() {
                                  selectedDate = date;
                                  widget.bookingData.date = date;
                                });
                              },
                              selectableDayPredicate: (DateTime day) {
                                return true;
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Choix du créneau
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSlotExpanded = !isSlotExpanded;
                  });
                },
                child: NeuBrutalismContainer(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Choisir un créneau',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedSlot ?? '',
                                  style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                if (selectedSlot != null) ...[
                                  const Icon(
                                    Icons.access_time,
                                    size: 30,
                                    color: AppColors.textColor,
                                  ),
                                ],
                              ],
                            ),
                            Icon(
                              isSlotExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: AppColors.textColor,
                            ),
                          ],
                        ),
                        if (isSlotExpanded) ...[
                          const SizedBox(height: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: isSlotExpanded
                                ? 300
                                : 0, // Hauteur maximale fixe quand déplié
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Midi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    children: generateTimeSlots('midi'),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Soir',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    children: generateTimeSlots('soir'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // Bouton suivant
              NeubrutalistButton(
                onPressed: widget.onNext,
                height: 60,
                backgroundColor: AppColors.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Suivant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8), // Espace entre le texte et l'icône
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction helper pour éviter la duplication de code
  Widget _buildSlotContent(DateTime slotTime, DateTime endTime, bool isFull) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 16), // Added margin to the left of the circle
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isFull ? Colors.orange[800] : Colors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isFull
                ? Icon(
                    Icons.pause,
                    color: Colors.white.withOpacity(0.5),
                    size: 15,
                  )
                : Icon(
                    Icons.check,
                    color: Colors.white.withOpacity(0.5),
                    size: 15,
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('HH:mm').format(slotTime),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFull
                ? Colors.orange
                : Colors.grey[300], // Fond orange si complet
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isFull ? Colors.orange : Colors.grey,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Text(
            isFull
                ? 'Complet'
                : 'Jusqu\'à ${DateFormat('HH:mm').format(endTime)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  // Fonction pour générer les créneaux horaires
  List<Widget> generateTimeSlots(String type) {
    List<Widget> slots = [];
    DateTime now = DateTime.now();
    DateTime noon = DateTime(now.year, now.month, now.day, 12, 0);
    DateTime evening = DateTime(now.year, now.month, now.day, 18, 0);

    if (type == 'midi') {
      for (int i = 0; i < 12; i++) {
        DateTime slotTime = noon.add(Duration(minutes: 15 * i));
        DateTime endTime = slotTime.add(Duration(hours: 1)); // Heure de fin
        bool isFull = i % 2 == 0; // Créneau complet si i est pair
        slots.add(
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSlot = DateFormat('HH:mm').format(slotTime);
                isSlotExpanded = false; // Rétracter le widget
              });
            },
            child: isFull
                ? DottedBorder(
                    color: selectedSlot == DateFormat('HH:mm').format(slotTime)
                        ? AppColors.secondaryColor
                        : Colors.black,
                    strokeWidth: 2,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            selectedSlot == DateFormat('HH:mm').format(slotTime)
                                ? AppColors.primaryColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _buildSlotContent(slotTime, endTime, isFull),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          selectedSlot == DateFormat('HH:mm').format(slotTime)
                              ? AppColors.primaryColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color:
                            selectedSlot == DateFormat('HH:mm').format(slotTime)
                                ? AppColors.secondaryColor
                                : Colors.black,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _buildSlotContent(slotTime, endTime, isFull),
                  ),
          ),
        );
        slots.add(const SizedBox(height: 15)); // Espace entre chaque créneau
      }
    } else if (type == 'soir') {
      for (int i = 0; i < 12; i++) {
        DateTime slotTime = evening.add(Duration(minutes: 15 * i));
        DateTime endTime = slotTime.add(Duration(hours: 1)); // Heure de fin
        bool isFull = i % 2 == 0; // Créneau complet si i est pair
        slots.add(
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSlot = DateFormat('HH:mm').format(slotTime);
                isSlotExpanded = false; // Rétracter le widget
              });
            },
            child: isFull
                ? DottedBorder(
                    color: selectedSlot == DateFormat('HH:mm').format(slotTime)
                        ? AppColors.secondaryColor
                        : Colors.black,
                    strokeWidth: 2,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            selectedSlot == DateFormat('HH:mm').format(slotTime)
                                ? AppColors.primaryColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _buildSlotContent(slotTime, endTime, isFull),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          selectedSlot == DateFormat('HH:mm').format(slotTime)
                              ? AppColors.primaryColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color:
                            selectedSlot == DateFormat('HH:mm').format(slotTime)
                                ? AppColors.secondaryColor
                                : Colors.black,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _buildSlotContent(slotTime, endTime, isFull),
                  ),
          ),
        );
        slots.add(const SizedBox(height: 15)); // Espace entre chaque créneau
      }
    }

    return slots;
  }
}
