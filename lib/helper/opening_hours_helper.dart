import 'package:flutter/material.dart';
import 'package:yummap/model/restaurant.dart';

class OpeningHoursHelper {
  /// Vérifie si le restaurant est ouvert à l'heure actuelle
  static bool isRestaurantOpen(Restaurant restaurant) {
    final now = DateTime.now();
    final currentDay =
        _getEnglishDayOfWeek(now.weekday); // Obtenir le jour en anglais
    final currentTime = TimeOfDay.fromDateTime(now);

    // Log des données reçues
    // print('Données reçues pour ${restaurant.name}: ${restaurant.schedule}');
    // print('Heure actuelle: ${currentTime.hour}:${currentTime.minute}');

    // Vérification du schedule
    if (restaurant.schedule.isEmpty) {
      print('❌ Pas d\'horaires définis pour ${restaurant.name}');
      return false;
    }

    // Obtenir les horaires pour le jour actuel
    final todayHours = restaurant.schedule[currentDay];
    if (todayHours == null || todayHours.isEmpty) {
      print('❌ Pas d\'horaires définis pour ${currentDay}');
      return false;
    }

    //print('Horaires pour ${currentDay}: ${todayHours.join(", ")}');

    // Pour chaque créneau horaire de la journée
    for (String timeSlot in todayHours) {
      // Format attendu: "HH:MM-HH:MM"
      final times = timeSlot.split('-');
      if (times.length != 2) continue;

      final opening = _parseTimeString(times[0].trim());
      final closing = _parseTimeString(times[1].trim());

      if (opening == null || closing == null) continue;

      int currentMinutes = currentTime.hour * 60 + currentTime.minute;
      int openMinutes = opening.hour * 60 + opening.minute;
      int closeMinutes = closing.hour * 60 + closing.minute;

      // Gérer le cas où le restaurant ferme après minuit
      if (closeMinutes < openMinutes) {
        closeMinutes += 24 * 60; // Ajouter 24 heures
        if (currentMinutes < openMinutes) {
          currentMinutes += 24 * 60; // Ajuster si avant minuit
        }
      }

      // Vérifier si l'heure actuelle est dans la plage
      if (currentMinutes >= openMinutes && currentMinutes <= closeMinutes) {
        // print(
        //     '✅ ${restaurant.name} est OUVERT dans ce créneau (${times[0]}-${times[1]}).');
        return true;
      }
    }

    //print('❌ ${restaurant.name} est FERMÉ - Aucun créneau correspondant.');
    return false;
  }

  // Fonction helper pour obtenir le jour en anglais
  static String _getEnglishDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  // Fonction helper pour obtenir le jour en français

  // Fonction helper pour parser une chaîne d'heure (format "HH:MM" ou "HH:MM AM/PM")
  static TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      String time = parts[0]; // "HH:MM"
      String? period = parts.length > 1 ? parts[1] : null; // "AM" ou "PM"

      final timeParts = time.split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Convertir en format 24 heures si nécessaire
      if (period != null) {
        if (period.toUpperCase() == 'PM' && hour != 12) {
          hour += 12; // Convertir PM en 24 heures
        } else if (period.toUpperCase() == 'AM' && hour == 12) {
          hour = 0; // Convertir 12 AM en 0 heures
        }
      }

      // Vérifier les limites
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Erreur de parsing pour l\'heure: $timeStr');
      return null;
    }
  }
}
