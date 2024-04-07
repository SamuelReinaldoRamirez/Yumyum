import 'package:tuple/tuple.dart'; // Importation du package tuple pour utiliser Tuple2

class Restaurant {
  final int id;
  final String name;
  final String address;
  final bool published;
  final double latitude;
  final double longitude;
  final List<String> videoLinks;
  final String phoneNumber;
  final List<int> tagStr;
  String placeId;
  final double ratings;
  final List<Review> reviews;
  final String price;
  final String websiteUrl;
  final bool handicap;
  final bool vege;
  final List<List<String>> schedule;
  final String pictureProfile;
  final int numberOfReviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.published,
    required this.latitude,
    required this.longitude,
    required this.videoLinks,
    required this.phoneNumber,
    required this.tagStr,
    required this.placeId,
    required this.ratings,
    required this.reviews,
    required this.price,
    required this.websiteUrl,
    required this.handicap,
    required this.vege,
    required this.schedule,
    required this.pictureProfile,
    required this.numberOfReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    List<List<String>> schedule = [];

    if (json['schedule'] != null && json['schedule'] is List<dynamic>) {
      List<dynamic> scheduleList = json['schedule'];
      if (scheduleList.isNotEmpty) {
        for (var item in scheduleList) {
          if (item is String) {
            List<String> daySchedule = [];

            // Convertir les jours en format standard
            List<String> splitItem = item.split(': ');
            if (splitItem.length == 2) {
              String day = splitItem[0];
              List<String> timeRanges = splitItem[1].split(', ');
              if (timeRanges.first != 'Closed') {
                // Si le jour n'est pas fermé
                for (var timeRange in timeRanges) {
                  // Convertir les horaires de 12 heures en format 24 heures
                  List<String> splitTimeRange = timeRange.split(' – ');
                  if (splitTimeRange.length == 2) {
                    String startTime12 = splitTimeRange[0].split(' ')[0];
                    String endTime12 = splitTimeRange[1].split(' ')[0];
                    String startTime24 = convertTo24HoursFormat(startTime12);
                    String endTime24 = convertTo24HoursFormat(endTime12);
                    daySchedule.add('$startTime24 - $endTime24');
                  }
                }
              }
              schedule.add(daySchedule);
            }
          }
        }
      } else {
        // Si la liste est vide, ajouter des listes vides pour chaque jour de la semaine
        for (int i = 0; i < 7; i++) {
          schedule.add([]);
        }
      }
    }

    // Parsing des autres données du restaurant
    List<String> videoLinks = [];
    if (json['video_links'] != null) {
      if (json['video_links'] is List<dynamic>) {
        for (dynamic link in json['video_links']) {
          if (link is String) {
            videoLinks.add(link);
          } else if (link is List<dynamic>) {
            for (dynamic subLink in link) {
              if (subLink is String) {
                videoLinks.add(subLink);
              }
            }
          }
        }
      } else if (json['video_links'] is String) {
        videoLinks.add(json['video_links']);
      }
    }

    List<int> tagsId =
        json['tags_id'] != null ? List<int>.from(json['tags_id']) : [];

    double latitude = 0.0;
    double longitude = 0.0;
    if (json['GPS_address'] != null && json['GPS_address']['data'] != null) {
      latitude = json['GPS_address']['data']['lat'] != null
          ? json['GPS_address']['data']['lat'].toDouble()
          : 0.0;
      longitude = json['GPS_address']['data']['lng'] != null
          ? json['GPS_address']['data']['lng'].toDouble()
          : 0.0;
    }

    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address_str'] ?? '',
      published: json['published'] ?? false,
      latitude: latitude,
      longitude: longitude,
      videoLinks: videoLinks,
      phoneNumber: json['phone_number'] ?? '',
      tagStr: tagsId,
      placeId: json['placeId'] ?? '',
      ratings: json['ratings'] != null ? json['ratings'].toDouble() : 0.0,
      reviews: [], // La liste des avis n'est pas fournie dans ce JSON, donc nous initialisons à une liste vide
      price: json['price'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      handicap: json['handicap'] ?? false,
      vege: json['vege'] ?? false,
      schedule: schedule, // Utilisation de la nouvelle structure pour l'horaire
      pictureProfile: json['picture_profile'] ?? '',
      numberOfReviews: json['number_of_reviews'] ?? 0,
    );
  }

  static String convertTo24HoursFormat(String time12) {
    List<String> timeParts = time12.split(':');
    if (timeParts.length == 2) {
      String hourMinute = timeParts[0];
      String periodPart =
          timeParts[1].trim(); // Enlever les espaces en début et fin de chaîne

      // Vérifier si l'indicateur AM/PM est présent dans la chaîne de période
      if (periodPart.contains('AM') || periodPart.contains('PM')) {
        // Récupérer l'heure et la période
        String hour = hourMinute;
        String period = periodPart.substring(
            periodPart.length - 2); // Récupérer les deux derniers caractères

        // Convertir l'heure en format 24 heures
        if (period == 'PM' && hour != '12') {
          hour = (int.parse(hour) + 12).toString();
        } else if (period == 'AM' && hour == '12') {
          hour = '00';
        }

        // Supprimer l'indicateur AM/PM de la partie de la période
        String minute = periodPart.substring(0, periodPart.length - 2).trim();

        // Formater l'heure en format 24 heures
        return '$hour:$minute';
      }
    }

    // Si le format du temps est incorrect ou s'il manque l'indicateur AM/PM, retourner l'entrée d'origine
    return time12;
  }

  List<String> getVideoLinks() {
    return videoLinks;
  }

  List<int> getTagStr() {
    return tagStr;
  }

  void setPlaceId(String placeId) {
    this.placeId = placeId;
  }

  String getPlaceId() {
    return placeId;
  }
}

class Review {
  final String author;
  final String text;
  final String rating;

  Review({
    required this.author,
    required this.text,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['author'] ?? '',
      text: json['text'] ?? '',
      rating: json['rating'] ?? '',
    );
  }
}
