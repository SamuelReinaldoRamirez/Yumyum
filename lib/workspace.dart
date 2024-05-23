import 'package:logger/logger.dart';

class Workspace {
  final int id;
  final String name;
  final String alias;
  final List<String> restaurants_placeId;


  Workspace({
    required this.id,
    required this.name,
    required this.alias,
    required this.restaurants_placeId,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    var logger = Logger();

    // Parsing des autres données du restaurant
    List<String> restaurants_placeID = [];
    print("JSON : ");
    print(json);
    if (json.containsKey('restaurants_placeID') && json['restaurants_placeID'] != null) {
      if (json['restaurants_placeID'] is List<dynamic>) {
        for (dynamic link in json['restaurants_placeID']) {
          if (link is String) {
            restaurants_placeID.add(link);
          } else  {
            print("WTF with placeID");
          }
        }
      } 
    }

    return Workspace(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      restaurants_placeId: restaurants_placeID,
    );
  }

}
