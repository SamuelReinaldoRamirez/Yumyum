class BookingModel {
  final String id;
  final String restaurantName;
  final String restaurantImage;
  final DateTime dateTime;
  final int numberOfPeople;
  final String status;
  final String userName;
  final String userPhone;

  BookingModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantImage,
    required this.dateTime,
    required this.numberOfPeople,
    required this.status,
    required this.userName,
    required this.userPhone,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      restaurantName: json['restaurant_name'],
      restaurantImage: json['restaurant_image'],
      dateTime: DateTime.parse(json['date_time']),
      numberOfPeople: json['number_of_people'],
      status: json['status'],
      userName: json['user_name'],
      userPhone: json['user_phone'],
    );
  }
}
