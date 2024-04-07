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
    if (json['schedule'] != null && json['schedule'] is Map) {
      Map<String, dynamic> scheduleMap = json['schedule'];
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      for (String day in days) {
        if (scheduleMap.containsKey(day)) {
          String scheduleOfDay = scheduleMap[day] ?? '';
          Tuple2<List<String>, bool> result =
              _formatScheduleOfDay(scheduleOfDay);
          if (result.item2) {
            schedule.add(result.item1);
          } else {
            schedule.add(['error']);
          }
        } else {
          schedule.add([]);
        }
      }
    }

    schedule = [
      ['08:10 - 14:00', '18:00 - 23:59'],
      ['09:00 - 12:00', '14:00 - 17:00', '18:00 - 21:00'],
      ['08:00 - 21:00'],
      ['18:00 - 21:00'],
      ['17:00 - 22:00'],
      ['11:00 - 14:00', '15:00 - 18:00', '19:00 - 22:00'],
      [],
    ];

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

  static Tuple2<List<String>, bool> _formatScheduleOfDay(String scheduleOfDay) {
    List<String> formattedSchedule = [];
    bool success = true;
    if (scheduleOfDay == 'Closed') {
      formattedSchedule = [];
    } else {
      List<String> timeRanges = scheduleOfDay.split(',');
      for (String timeRange in timeRanges) {
        List<String> times = timeRange.split('–').map((e) => e.trim()).toList();
        if (times.length != 2) {
          success = false;
          break;
        }
        String formattedStartTime = _convertTo24HourFormat(times[0]);
        String formattedEndTime = _convertTo24HourFormat(times[1]);
        formattedSchedule.add('$formattedStartTime - $formattedEndTime');
      }
    }
    return Tuple2<List<String>, bool>(formattedSchedule, success);
  }

  static String _convertTo24HourFormat(String time) {
    List<String> parts = time.split(' ');
    String hourMinute = parts[0];
    String period = parts[1];

    List<String> hourMinuteParts = hourMinute
        .split('–')
        .map((e) => e.trim())
        .toList(); // Utilisation du tiret standard
    int hour = int.parse(hourMinuteParts[0].split(':')[0]);
    int minute = int.parse(hourMinuteParts[0].split(':')[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
