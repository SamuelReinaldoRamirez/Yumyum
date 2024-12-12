// ignore_for_file: non_constant_identifier_names, avoid_print

class Workspace {
  final int id;
  final String name;
  final String alias;
  final List<String> restaurants_placeId;
  bool isFollowed;

  Workspace({
    required this.id,
    required this.name,
    required this.alias,
    required this.restaurants_placeId,
    this.isFollowed = false,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    // Parsing des autres données du restaurant
    List<String> restaurantsPlaceid = [];
    print("JSON : ");
    print(json);
    if (json.containsKey('restaurants_placeID') &&
        json['restaurants_placeID'] != null) {
      if (json['restaurants_placeID'] is List<dynamic>) {
        for (dynamic link in json['restaurants_placeID']) {
          if (link is String) {
            restaurantsPlaceid.add(link);
          } else {
            print("WTF with placeID");
          }
        }
      }
    }

    return Workspace(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      restaurants_placeId: restaurantsPlaceid,
      isFollowed: json['is_followed'] ?? false,
    );
  }

  get placeIds => restaurants_placeId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'is_followed': isFollowed,
    };
  }
}
