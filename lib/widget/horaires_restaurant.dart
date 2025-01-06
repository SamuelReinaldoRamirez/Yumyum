// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';

class HorairesRestaurant extends StatefulWidget {
  final Map<String, List<String>> schedule;

  const HorairesRestaurant({Key? key, required this.schedule})
      : super(key: key);

  @override
  _HorairesRestaurantState createState() => _HorairesRestaurantState();
}

class _HorairesRestaurantState extends State<HorairesRestaurant> {
  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _getDayOfWeek(DateTime.now().weekday);
  }

  @override
  Widget build(BuildContext context) {
    bool allDaysEmpty =
        widget.schedule.values.every((element) => element.isEmpty);
    bool selectedDayEmpty = widget.schedule[_selectedDay]?.isEmpty ?? true;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) {
                  String dayName =
                      _getDayOfWeek((DateTime.monday + index - 1) % 7 + 1);
                  bool isSelected = _selectedDay == dayName;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDay = dayName;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textColor,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        dayName.substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 50.0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF646165),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    if (allDaysEmpty || selectedDayEmpty)
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            allDaysEmpty
                                ? 'Horaires indisponibles'
                                : _getClosedText(_selectedDay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildOpeningHoursBox(constraints.maxWidth),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(int index) {
    if (index < 1 || index > 7) {
      return 'Monday';
    }
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

  String _getClosedText(String day) {
    if (widget.schedule[day] != null &&
        widget.schedule[day]!.contains('Closed')) {
      return 'Fermé';
    } else if (widget.schedule[day] != null &&
        widget.schedule[day]!.contains('Fermé')) {
      return 'Fermé';
    } else if (widget.schedule[day] != null &&
        widget.schedule[day]!.contains('Sunday: Closed')) {
      return 'Sunday: Fermé';
    } else {
      return 'Fermé';
    }
  }

  static const double SAFETY_MARGIN = 8.0; // Marge de sécurité en pixels

  Widget _buildOpeningHoursBox(double containerWidth) {
    List<String> times = widget.schedule[_selectedDay] ?? [];
    times.sort((a, b) {
      var startTimeA = a.split(' - ')[0];
      var startTimeB = b.split(' - ')[0];
      return _convertToMinutes(startTimeA)
          .compareTo(_convertToMinutes(startTimeB));
    });

    List<Widget> openingHourBoxes = [];
    List<Widget> openingHourTexts = [];

    for (String time in times) {
      // Remplacer le tiret long par le tiret simple
      time = time.replaceAll(' – ', ' - ');

      List<String> parts = time.split(' - ');
      if (parts.length != 2) continue;

      String startTimeString = parts[0].trim();
      String endTimeString = parts[1].trim();

      try {
        double startTime = _convertToMinutes(startTimeString).toDouble();
        double endTime = _convertToMinutes(endTimeString).toDouble();

        if (endTime < startTime) {
          // Cas où l'heure de fin est après minuit
          _addHourSegment(startTime, 1440, startTimeString, '11:59 PM',
              containerWidth, openingHourBoxes, openingHourTexts);
          _addHourSegment(0, endTime, '12:00 AM', endTimeString, containerWidth,
              openingHourBoxes, openingHourTexts);
        } else {
          // Cas normal
          _addHourSegment(startTime, endTime, startTimeString, endTimeString,
              containerWidth, openingHourBoxes, openingHourTexts);
        }
      } catch (e) {
        print('Erreur de conversion: $e');
      }
    }
    return Stack(
      children: openingHourBoxes + openingHourTexts,
    );
  }

  void _addHourSegment(
      double startTime,
      double endTime,
      String startTimeLabel,
      String endTimeLabel,
      double containerWidth,
      List<Widget> boxes,
      List<Widget> labels) {
    double startPercentage = (startTime / (24 * 60)) * 100;
    double endPercentage = (endTime / (24 * 60)) * 100;
    double widthPercentage = endPercentage - startPercentage;

    boxes.add(
      Positioned(
        left: startPercentage * containerWidth / 100,
        child: Container(
          width: widthPercentage * containerWidth / 100,
          height: 50.0,
          // Remplacer par la couleur principale de l'application
          color: AppColors.primaryColor,
        ),
      ),
    );

    if (startTimeLabel != '11:59 PM' && startTimeLabel != '12:00 AM') {
      final textPainter = TextPainter(
        text: TextSpan(
          text: startTimeLabel,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // Calcule les dimensions du texte
      double textWidth = textPainter.width;

      double leftPosition = startPercentage * containerWidth / 100 - 20;
      if (leftPosition < SAFETY_MARGIN) {
        leftPosition = SAFETY_MARGIN;
      }

      labels.add(
        Positioned(
          left: leftPosition,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              startTimeLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
      );
    }

    if (endTimeLabel != '11:59 PM' && endTimeLabel != '12:00 AM') {
      final textPainter = TextPainter(
        text: TextSpan(
          text: endTimeLabel,
          style: TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // Calcule les dimensions du texte
      double textWidth = textPainter.width;

      double rightPosition = (100 - endPercentage) * containerWidth / 100 - 20;
      if (rightPosition + textWidth > containerWidth - SAFETY_MARGIN) {
        rightPosition = containerWidth - textWidth - SAFETY_MARGIN;
      }

      labels.add(
        Positioned(
          right: rightPosition,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              endTimeLabel,
              style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
      );
    }
  }

  int _convertToMinutes(String timeStr) {
    // Exemple de format: "12:00 AM" ou "1:00 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (parts.length > 1 && parts[1] == 'PM' && hour != 12) {
      hour += 12; // Convertir PM en format 24h
    } else if (parts.length > 1 && parts[1] == 'AM' && hour == 12) {
      hour = 0; // Convertir 12 AM en 0h
    }

    return hour * 60 + minute; // Retourne le temps en minutes
  }
}
