import 'package:logger/logger.dart';

class Restaurant {
 
  final int id;
  final String name;
  final String address;
  final List<String> videoLinks;
  final double longitude;
  final double latitude;
  final List<String> tagStr;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.videoLinks,
    required this.longitude,
    required this.latitude,
    required this.tagStr,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final logger = Logger();
    logger.e(json['name']);
    if(json['name'] == 'Bao Express'){
      logger.e("TROUVE");
    }


    List<String> videoLinks = [];
    if (json.containsKey('video_links') && json['video_links'] != null && json['video_links'] != []) {
      videoLinks = List<String>.from(json['video_links']);
    }else{
      videoLinks = [];
    }

    List<String> tagStr = [];
    if (json.containsKey('str_tags') && json['str_tags'] != null && json['str_tags'] != []) {
      tagStr = List<String>.from(json['str_tags']);
    }else{
      tagStr = [];
    }
 

    double longitude = json['GPS_address']['data']['lng'] != null ? json['GPS_address']['data']['lng'].toDouble() : 0.0;
    double latitude = json['GPS_address']['data']['lat'] != null ? json['GPS_address']['data']['lat'].toDouble() : 0.0;

    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address_str'] ?? '',
      videoLinks: videoLinks,
      longitude: longitude,
      latitude: latitude,
      tagStr: tagStr,
    );
  }

    List<String> getVideoLinks() {
    return videoLinks;
  }

  List<String> getTagStr() {
    return tagStr;
  }
  

}

