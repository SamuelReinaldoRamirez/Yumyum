import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importation de la bibliothèque Intl pour le formatage de la date
import 'package:yummap/constant/theme.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/widget/neu_brutalism_container.dart';
import '../../models/booking_data.dart';
import '../neubrutalist/neubrutalist_button.dart';
import 'package:dotted_border/dotted_border.dart';

class BookingStepOne extends StatefulWidget {
  final BookingData bookingData;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final Restaurant restaurant; // Ajout du restaurant

  const BookingStepOne({
    Key? key,
    required this.bookingData,
    required this.onNext,
    required this.onClose,
    required this.restaurant, // Ajout du restaurant dans le constructeur
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
  final ScrollController _slotsScrollController = ScrollController();
  double _lastScrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.bookingData.date;
    selectedCovers = widget.bookingData.covers;
    _slotsScrollController.addListener(() {
      _lastScrollPosition = _slotsScrollController.offset;
    });
  }

  @override
  void dispose() {
    _slotsScrollController.dispose();
    super.dispose();
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_slotsScrollController.hasClients && isSlotExpanded) {
        _slotsScrollController.jumpTo(_lastScrollPosition);
      }
    });
  }

  // Ajout des méthodes utilitaires pour gérer les horaires
  bool isRestaurantOpenOnDate(DateTime date) {
    String dayName = _getDayOfWeek(date.weekday);
    final schedule = widget.restaurant.schedule[dayName];
    return schedule != null &&
        schedule.isNotEmpty &&
        !schedule.contains('Closed') &&
        !schedule.contains('Fermé');
  }

  String _getDayOfWeek(int index) {
    if (index < 1 || index > 7) return 'Monday';
    return [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][index - 1];
  }

  List<TimeSlot> getAvailableTimeSlots(DateTime date) {
    String dayName = _getDayOfWeek(date.weekday);
    final schedule = widget.restaurant.schedule[dayName];
    List<TimeSlot> slots = [];

    if (schedule == null || schedule.isEmpty) return slots;

    DateTime now = DateTime.now();
    bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    for (String timeRange in schedule) {
      if (timeRange.contains('Closed') || timeRange.contains('Fermé')) continue;

      List<String> parts = timeRange.split(' - ');
      if (parts.length != 2) continue;

      DateTime startTime = _parseTimeString(parts[0].trim(), date);
      DateTime endTime = _parseTimeString(parts[1].trim(), date);

      // Si l'heure de fin est avant l'heure de début, on considère que c'est le lendemain
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      // On arrête les réservations 1h avant la fin du service
      endTime = endTime.subtract(const Duration(hours: 1));

      // Générer des créneaux de 30 minutes
      DateTime currentSlot = startTime;
      while (currentSlot.isBefore(endTime)) {
        // Pour aujourd'hui, ne pas proposer de créneaux déjà passés
        if (!isToday || currentSlot.isAfter(now)) {
          slots.add(TimeSlot(
            startTime: currentSlot,
            endTime: currentSlot.add(const Duration(minutes: 30)),
            isAvailable: true,
          ));
        }
        currentSlot = currentSlot.add(const Duration(minutes: 30));
      }
    }

    return slots;
  }

  DateTime _parseTimeString(String timeStr, DateTime date) {
    // Convertir le format 12h en 24h si nécessaire
    final RegExp amPmRegex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?');
    final match = amPmRegex.firstMatch(timeStr);

    if (match != null) {
      int hours = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      String? amPm = match.group(3);

      if (amPm != null) {
        if (amPm.toUpperCase() == 'PM' && hours < 12) hours += 12;
        if (amPm.toUpperCase() == 'AM' && hours == 12) hours = 0;
      }

      return DateTime(
        date.year,
        date.month,
        date.day,
        hours,
        minutes,
      );
    }

    // Format 24h par défaut
    final parts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
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
                                    size: 30, color: AppColors.textColor),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(selectedDate),
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
                          const SizedBox(height: 16),
                          CalendarDatePicker(
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 90)), // Augmenté à 90 jours
                            onDateChanged: (date) {
                              if (isRestaurantOpenOnDate(date)) {
                                setState(() {
                                  selectedDate = date;
                                  selectedSlot =
                                      null; // Réinitialiser le créneau sélectionné
                                  isDateExpanded =
                                      false; // Fermer le calendrier
                                  isSlotExpanded =
                                      true; // Ouvrir la sélection de créneau
                                });
                              }
                            },
                            selectableDayPredicate: (date) {
                              return isRestaurantOpenOnDate(date);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sélection du créneau horaire
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSlotExpanded = !isSlotExpanded;
                    if (isSlotExpanded) {
                      _restoreScrollPosition();
                    }
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
                              'Créneau horaire',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 30, color: AppColors.textColor),
                                const SizedBox(width: 8),
                                Text(
                                  selectedSlot ?? 'Choisir un créneau',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
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
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              controller: _slotsScrollController,
                              itemCount:
                                  getAvailableTimeSlots(selectedDate).length,
                              itemBuilder: (context, index) {
                                final slot =
                                    getAvailableTimeSlots(selectedDate)[index];
                                final isSelected = selectedSlot ==
                                    DateFormat('HH:mm').format(slot.startTime);

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedSlot = DateFormat('HH:mm')
                                            .format(slot.startTime);
                                        widget.bookingData.timeSlot =
                                            selectedSlot!;
                                        isSlotExpanded = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: AppColors.textColor,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${DateFormat('HH:mm').format(slot.startTime)} - ${DateFormat('HH:mm').format(slot.endTime)}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.textColor,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (slot.isAvailable)
                                            Text(
                                              'Disponible',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });
}
