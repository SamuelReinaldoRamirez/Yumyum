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
    return Tag(
      id: json['id'] ?? 0,
      tag: json['tag'] ?? '',
      type: json['type'] ?? '',
    );
  }

}

