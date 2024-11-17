class Hotel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;

  Hotel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'],
      address: json['adresse'],
      latitude: json['gps']['data']['lat'],
      longitude: json['gps']['data']['lng'],
      photoUrl: json['photo_url'],
    );
  }
}
