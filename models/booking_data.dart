class BookingData {
  DateTime date;
  String timeSlot;
  int covers;
  String firstName;
  String lastName;
  String phone;
  String email;
  String title;
  bool saveInfo;

  BookingData({
    required this.date,
    required this.timeSlot,
    required this.covers,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.title = 'M.',
    this.saveInfo = false,
  });
}
