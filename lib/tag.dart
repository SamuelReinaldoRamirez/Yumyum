import 'package:logger/logger.dart';

class Tag {
 
  final int id;
  final String tag;
  final String type;


  Tag({
    required this.id,
    required this.tag,
    required this.type,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    final logger = Logger();
    logger.e(json['tag']);

    return Tag(
      id: json['id'] ?? 0,
      tag: json['tag'] ?? '',
      type: json['type'] ?? '',
    );
  }

}

