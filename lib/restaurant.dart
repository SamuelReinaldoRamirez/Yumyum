import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';
import 'package:yummap/review_interface.dart';

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
  final List<ReviewRestau> reviews;
  final String price;
  final String websiteUrl;
  final bool handicap;
  final bool vege;
  final Map<String, List<String>> schedule;
  final String pictureProfile;
  final int numberOfReviews;
  final String cuisine;

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
    required this.cuisine,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var logger = Logger();
    Map<String, List<String>> schedule = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': []
    };

    // Parsing des reviews
    List<ReviewRestau> reviews = [];
    if (json.containsKey('reviews') && json['reviews'] != null) {
      if (json['reviews'] is List<dynamic>) {
        for (dynamic review in json['reviews']) {
          if (review is Map<String, dynamic>) {
            reviews.add(ReviewRestau.fromJson(review));
          }
        }
      }
    }

    // Parsing du planning
    if (json.containsKey('schedule') &&
        json['schedule'] != null &&
        json['schedule'] is List<dynamic>) {
      List<dynamic> scheduleList = json['schedule'];
      for (var item in scheduleList) {
        if (item is String) {
          List<String> splitItem = item.split(': ');
          if (splitItem.length == 2) {
            String day = splitItem[0];
            List<String> timeRanges = splitItem[1].split(', ');

            if (schedule.containsKey(day)) {
              // Ajout des horaires au jour approprié
              for (var timeRange in timeRanges) {
                if (timeRange.isNotEmpty) {
                  schedule[day]?.add(timeRange.trim());
                }
              }
            }
          }
        }
      }
    }

    if (json['id'] == 32) {
      schedule = {
        'Monday': ['12:00 PM – 2:30 PM', '7:00 PM – 10:30 PM'],
        'Tuesday': ['12:00 PM – 2:30 PM', '7:00 PM – 10:30 PM'],
        'Wednesday': ['12:00 PM – 2:30 PM'],
        'Thursday': ['7:00 PM – 10:30 PM'],
        'Friday': ['12:00 PM – 2:30 PM', '7:00 PM – 10:30 PM'],
        'Saturday': ['7:00 PM – 10:30 PM'],
        'Sunday': [],
      };
    }

    // logger.d(schedule);

    // Parsing des autres données du restaurant
    List<String> videoLinks = [];
    if (json.containsKey('video_links') && json['video_links'] != null) {
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
    if (json.containsKey('GPS_address') &&
        json['GPS_address'] != null &&
        json['GPS_address']['data'] != null) {
      latitude = json['GPS_address']['data']['lat'] != null
          ? json['GPS_address']['data']['lat'].toDouble()
          : 0.0;
      longitude = json['GPS_address']['data']['lng'] != null
          ? json['GPS_address']['data']['lng'].toDouble()
          : 0.0;
    }

    double ratings = 0.0;
    if (json.containsKey('ratings')) {
      if (json['ratings'] is double) {
        ratings = json['ratings'];
      } else if (json['ratings'] is String) {
        ratings = double.tryParse(json['ratings']) ?? 0.0;
        // logger.d('Conversion de ratings String vers double: $ratings');
      } else if (json['ratings'] is int) {
        ratings = (json['ratings'] as int).toDouble();
        // logger.d('Conversion de ratings int vers double: $ratings');
      } else {
        logger.e('Type inattendu pour ratings: ${json['ratings'].runtimeType}');
      }
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
      ratings: ratings, // Utilisation de la valeur convertie et loggée
      reviews: reviews,
      price: json['price'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      handicap: json['handicap'] ?? false,
      vege: json['vege'] ?? false,
      schedule: schedule, // Utilisation de la nouvelle structure pour l'horaire
      pictureProfile: json['picture_profile'] ?? '',
      numberOfReviews: json['number_of_reviews'] ?? 0,
      cuisine: json.containsKey('cuisine')
          ? json['cuisine']['cuisine_name'] ?? ''
          : '',
    );
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

  List<ReviewRestau> getReviews() {
    return reviews;
  }
}

class ReviewRestau implements ReviewInterface {
  final String _author;
  final String text;
  final double _rating;

  ReviewRestau({
    required String author,
    required this.text,
    required double rating,
  })  : _author = author,
        _rating = rating;

  @override
  String get comment => text;

  @override
  double get rating => _rating;

  @override
  String get author => _author;

  @override
  String get type => "google reviews".tr();

  factory ReviewRestau.fromJson(Map<String, dynamic> json) {
    return ReviewRestau(
      author: json['author'] ?? '',
      text: json['text'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}
