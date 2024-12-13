// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF95A472)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            dayName.substring(
                                0, 3), // Utilisation des 3 premières lettres
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF646165),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                            allDaysEmpty ? 'Horaires indisponibles' : 'Fermé',
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

  Widget _buildOpeningHoursBox(double containerWidth) {
    List<String> times = widget.schedule[_selectedDay] ?? [];
    times.sort((a, b) {
      var startTimeA = a.split(' – ')[0];
      var startTimeB = b.split(' – ')[0];
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
          color: const Color(0xFF95A472),
        ),
      ),
    );

    if (startTimeLabel != '11:59 PM' && startTimeLabel != '12:00 AM') {
      labels.add(
        Positioned(
          left: (startPercentage / 100) * containerWidth - 15,
          bottom: 30,
          child: Text(
            startTimeLabel,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (endTimeLabel != '11:59 PM' && endTimeLabel != '12:00 AM') {
      labels.add(
        Positioned(
          left:
              ((startPercentage + widthPercentage) / 100) * containerWidth - 15,
          bottom: 3,
          child: Text(
            endTimeLabel,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFFFFF00),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }

  int _convertToMinutes(String time) {
    try {
      var parts = time.split(' ');
      var timeParts = parts[0].split(':');
      var hours = int.parse(timeParts[0]);
      var minutes = int.parse(timeParts[1]);
      var period = parts[1];

      if (period == 'PM' && hours != 12) {
        hours += 12;
      } else if (period == 'AM' && hours == 12) {
        hours = 0;
      }

      return hours * 60 + minutes;
    } catch (e) {
      print('Erreur de conversion: $e');
      return 0; // Valeur par défaut en cas d'erreur
    }
  }
}
