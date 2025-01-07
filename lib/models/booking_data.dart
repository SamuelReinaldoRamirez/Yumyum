class BookingData {
  int covers;
  DateTime date;
  String timeSlot;
  String title;
  String firstName;
  String lastName;
  String phone;
  String email;
  String comment;
  bool saveInfo;
  bool acceptTerms;

  BookingData({
    required this.covers,
    required this.date,
    required this.timeSlot,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.comment = '',
    this.saveInfo = false,
    this.acceptTerms = false,
  });
}
