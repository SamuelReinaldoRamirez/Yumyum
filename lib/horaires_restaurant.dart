import 'package:flutter/material.dart';

class HorairesRestaurant extends StatefulWidget {
  @override
  _HorairesRestaurantState createState() => _HorairesRestaurantState();
}

class _HorairesRestaurantState extends State<HorairesRestaurant> {
  late int _selectedDayIndex; // Index du jour sélectionné
  // Horaires fictives pour chaque jour de la semaine
  List<List<String>> horaires = [
    ['00:10 - 14:00', '18:00 - 23:59'],
    ['09:00 - 12:00', '14:00 - 17:00', '18:00 - 21:00'],
    ['08:00 - 21:00'],
    ['18:00 - 21:00'],
    ['17:00 - 22:00'],
    ['11:00 - 14:00', '15:00 - 18:00', '19:00 - 22:00'],
    [],
  ];

  @override
  void initState() {
    super.initState();
    // Récupérer l'index du jour actuel
    _selectedDayIndex = DateTime.now().weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) {
                  DateTime currentDate = DateTime.now();
                  int jourDeLaSemaine = currentDate
                      .weekday; // Obtenir le jour de la semaine (1 pour lundi, 2 pour mardi, ..., 7 pour dimanche)
                  int ajustement = jourDeLaSemaine == DateTime.monday
                      ? 0
                      : jourDeLaSemaine - 1;
                  currentDate.add(Duration(
                      days: index +
                          1 -
                          ajustement)); // Ajouter 1 - ajustement pour décaler les jours
                  String dayName = _getDayOfWeek((DateTime.monday + index - 1) %
                      7); // Utiliser DateTime.monday comme premier jour

                  bool isSelected = _selectedDayIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Color(0xFF95A472) : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            dayName,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Color(0xFF646165),
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
          SizedBox(height: 1.0),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 50.0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF646165),
                        borderRadius: BorderRadius.circular(
                            5.0), // Ajout des bords arrondis
                      ),
                    ),
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

  // Fonction utilitaire pour obtenir le nom du jour de la semaine en fonction de l'index
  String _getDayOfWeek(int index) {
    return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][index];
  }

  // Construction du carré d'heures d'ouverture
  Widget _buildOpeningHoursBox(double containerWidth) {
    List<String> times = horaires[_selectedDayIndex];
    times.sort((a, b) {
      // Trier par heure de début
      var startTimeA = a.split(' - ')[0];
      var startTimeB = b.split(' - ')[0];
      return _convertToMinutes(startTimeA)
          .compareTo(_convertToMinutes(startTimeB));
    });

    List<Widget> openingHourBoxes = [];
    List<Widget> openingHourTexts = [];

    for (String time in times) {
      List<String> parts = time.split(' - ');
      double startTime = _convertToMinutes(parts[0]).toDouble();
      double endTime = _convertToMinutes(parts[1]).toDouble();
      double startPercentage = (startTime / (24 * 60)) * 100;
      double endPercentage = (endTime / (24 * 60)) * 100;
      double widthPercentage = (endPercentage - startPercentage);

      openingHourBoxes.add(
        Positioned(
          left: startPercentage * containerWidth / 100,
          child: Container(
            width: widthPercentage * containerWidth / 100,
            height: 50.0,
            color: Color(0xFF95A472),
          ),
        ),
      );

      openingHourTexts.add(
        Positioned(
          left: (startPercentage / 100) * containerWidth - 15,
          bottom: 30,
          child: Text(
            parts[0],
            style: TextStyle(
                fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
      openingHourTexts.add(
        Positioned(
          left:
              ((startPercentage + widthPercentage) / 100) * containerWidth - 15,
          bottom: 3,
          child: Text(
            parts[1],
            style: TextStyle(
                fontSize: 13,
                color: Color(0xFFFFFF00),
                fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    return Stack(
      children: openingHourBoxes + openingHourTexts,
    );
  }

  // Fonction utilitaire pour convertir l'heure au format hh:mm en minutes
  int _convertToMinutes(String time) {
    var parts = time.split(':');
    var hours = int.parse(parts[0]);
    var minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }
}
