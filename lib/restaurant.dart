import 'package:logger/logger.dart';

class Restaurant {
 
  final int id;
  final String name;
  final String address;
  final List<String> videoLinks;
  final double longitude;
  final double latitude;
  final List<int> tagStr;

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
    //logger.e(json['name']);
    if(json['name'] == 'Bao Express'){
      logger.e("BAO EXPRESS");
    }


    List<String> videoLinks = [];
    if (json.containsKey('video_links') && json['video_links'] != null && json['video_links'] != []) {
      videoLinks = List<String>.from(json['video_links']);
    }else{
      videoLinks = [];
    }

    List<int> tagStr = [];
    logger.d(json['tags_id']);
    if (json.containsKey('tags_id') && json['tags_id'] != null && json['tags_id'] != []) {
      tagStr = List<int>.from(json['tags_id']);
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

  List<int> getTagStr() {
    return tagStr;
  }
  

}

